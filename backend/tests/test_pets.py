import copy
import json
import sys
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path
from uuid import uuid4

import boto3
from moto import mock_aws

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'pets'))

from app import handle_request
from service import Conflict, PetError, PetService
from store import PetStore


class PetsTests(unittest.TestCase):
    def setUp(self):
        self.aws = mock_aws()
        self.aws.start()
        self.addCleanup(self.aws.stop)
        self.client = boto3.client('dynamodb', region_name='ap-southeast-2')
        self.client.create_table(
            TableName='pets', BillingMode='PAY_PER_REQUEST',
            AttributeDefinitions=[
                {'AttributeName': 'owner', 'AttributeType': 'S'},
                {'AttributeName': 'record', 'AttributeType': 'S'},
            ],
            KeySchema=[
                {'AttributeName': 'owner', 'KeyType': 'HASH'},
                {'AttributeName': 'record', 'KeyType': 'RANGE'},
            ],
        )
        self.store = PetStore('pets', self.client)
        self.now = datetime(2026, 10, 13, tzinfo=timezone.utc)
        self.service = PetService(self.store, lambda: self.now)

    def request(self, owner, route, body=None, token_use='access'):
        return handle_request({
            'routeKey': route,
            'requestContext': {'authorizer': {'jwt': {'claims': {
                'sub': owner, 'token_use': token_use,
            }}}},
            'body': json.dumps(body) if body is not None else '',
        }, self.service)

    def mutation(self, operation, value, owner='alice', request_id=None):
        field = {'selection': 'pet_id', 'purchases': 'item_id',
                 'actions': 'action_id'}[operation]
        body = {field: value, 'version': self.service.read(owner)['version'],
                'request_id': request_id or str(uuid4())}
        return body, self.service.mutate(owner, operation, body)

    def test_initialisation_and_account_isolation(self):
        alice = self.service.read('alice')
        self.assertEqual(alice['selected_pet_id'], 'puppy')
        self.assertEqual(alice['pet']['coins'], 0)
        self.service.credit_trip('alice', 'trip-1', 10)
        self.mutation('selection', 'koala')
        self.mutation('purchases', 'water')
        self.mutation('actions', 'sunlight')

        bob = self.service.read('bob')
        self.assertEqual(bob['selected_pet_id'], 'puppy')
        self.assertEqual(bob['inventory'], {})
        self.assertEqual(bob['pet']['coins'], 0)
        self.assertEqual(bob['co2_saved_kg'], 0)
        self.mutation('actions', 'sunlight', owner='bob')
        self.assertEqual(self.service.read('alice')['selected_pet_id'], 'koala')

    def test_authentication_and_client_owner_override(self):
        for owner, token in [('', 'access'), ('alice', 'id')]:
            response = self.request(owner, 'GET /v1/me/pet', token_use=token)
            self.assertEqual(response['statusCode'], 401)
        response = handle_request({'routeKey': 'GET /v1/me/pet'}, self.service)
        self.assertEqual(response['statusCode'], 401)
        body = {'pet_id': 'puppy', 'version': 0, 'request_id': str(uuid4()),
                'owner': 'bob'}
        response = self.request('alice', 'PUT /v1/me/pet/selection', body)
        self.assertEqual(response['statusCode'], 400)
        self.assertIsNone(self.store.load('bob'))

    def test_locked_and_unknown_pets(self):
        for pet_id, code in [('koala', 'pet_locked'), ('fake', 'unknown_pet')]:
            with self.assertRaises(PetError) as error:
                self.mutation('selection', pet_id)
            self.assertEqual(error.exception.code, code)
        self.assertEqual(self.service.read('alice')['version'], 0)

    def test_purchase_and_care_are_atomic_and_clamped(self):
        self.service.credit_trip('alice', 'trip-1', 5)
        self.mutation('purchases', 'water')
        _, result = self.mutation('actions', 'water')
        self.assertEqual(result['pet']['coins'], 45)
        self.assertEqual(result['inventory']['water'], 0)
        self.assertEqual(result['pet']['health'], 1)
        before = self.service.read('alice')
        with self.assertRaises(PetError):
            self.mutation('actions', 'water')
        self.assertEqual(self.service.read('alice'), before)

    def test_insufficient_coins_and_duplicate_durable_purchase(self):
        with self.assertRaises(PetError) as error:
            self.mutation('purchases', 'water')
        self.assertEqual(error.exception.code, 'insufficient_coins')
        self.service.credit_trip('alice', 'trip-1', 10)
        self.mutation('purchases', 'kennel')
        before = self.service.read('alice')
        with self.assertRaises(PetError) as error:
            self.mutation('purchases', 'kennel')
        self.assertEqual(error.exception.code, 'already_owned')
        self.assertEqual(self.service.read('alice'), before)

    def test_retry_and_request_id_reuse(self):
        self.service.credit_trip('alice', 'trip-1', 10)
        body, result = self.mutation('purchases', 'water')
        self.assertEqual(self.service.mutate('alice', 'purchases', body), result)
        self.assertEqual(self.service.read('alice')['pet']['coins'], 95)
        body['item_id'] = 'fertiliser'
        with self.assertRaises(PetError) as error:
            self.service.mutate('alice', 'purchases', body)
        self.assertEqual(error.exception.code, 'request_conflict')
        body['item_id'] = 'water'
        body['version'] = 0
        self.service.credit_trip('bob', 'trip-1', 10)
        body['version'] = self.service.read('bob')['version']
        result = self.service.mutate('bob', 'purchases', body)
        self.assertEqual(result['pet']['coins'], 95)

    def test_stale_version_and_transaction_rollback(self):
        self.service.credit_trip('alice', 'trip-1', 10)
        old = self.store.load('alice')
        self.mutation('purchases', 'water')
        before = self.service.read('alice')
        outdated = copy.deepcopy(old)
        outdated['coins'] = 0
        outdated['version'] += 1
        with self.assertRaises(Conflict):
            self.store.commit('alice', old['version'], outdated,
                              'request:stale', 'hash', {})
        self.assertIsNone(self.store.receipt('alice', 'request:stale'))
        self.assertEqual(self.service.read('alice'), before)
        body = {'item_id': 'water', 'version': old['version'],
                'request_id': str(uuid4())}
        with self.assertRaises(PetError) as error:
            self.service.mutate('alice', 'purchases', body)
        self.assertEqual(error.exception.code, 'stale_version')

    def test_trip_credit_is_once_per_user_and_trip(self):
        first = self.service.credit_trip('alice', 'trip-1', 5)
        self.assertEqual(self.service.credit_trip('alice', 'trip-1', 5.0), first)
        with self.assertRaises(PetError):
            self.service.credit_trip('alice', 'trip-1', 6)
        self.service.credit_trip('bob', 'trip-1', 5)
        self.assertEqual(self.service.read('bob')['pet']['coins'], 50)
        self.assertEqual(self.service.read('alice')['co2_saved_kg'], 5)

    def test_pet_care_and_adoption_date_survive_switching(self):
        self.service.credit_trip('alice', 'trip-1', 5)
        state = self.store.load('alice')
        state['pets']['puppy']['health'] = 0.4
        self.client.update_item(
            TableName='pets', Key=self.store._key('alice', 'state'),
            UpdateExpression='SET payload = :payload',
            ExpressionAttributeValues={':payload': {'S': json.dumps(state)}},
        )
        adopted = self.service.read('alice')['adopted_at']
        self.now += timedelta(days=3)
        self.mutation('selection', 'koala')
        _, result = self.mutation('selection', 'puppy')
        self.assertEqual(result['adopted_at'], adopted)
        self.assertEqual(result['pet']['days_together'], 3)
        self.assertEqual(result['pet']['health'], 0.4)

    def test_sunlight_cooldown(self):
        _, state = self.mutation('actions', 'sunlight')
        self.assertEqual(state['server_time'], '2026-10-13T00:00:00Z')
        self.assertEqual(state['cooldowns']['sunlight'], '2026-10-13T01:00:00Z')
        with self.assertRaises(PetError) as error:
            self.mutation('actions', 'sunlight')
        self.assertEqual(error.exception.code, 'cooldown')
        self.now += timedelta(hours=1)
        self.assertEqual(self.service.read('alice')['cooldowns'], {})
        self.mutation('actions', 'sunlight')

    def test_invalid_requests_and_unexposed_trip_route(self):
        for body in [[], {'coins': 999}, {'action_id': 'sunlight',
                     'version': True, 'request_id': str(uuid4())}]:
            result = self.request('alice', 'POST /v1/me/pet/actions', body)
            self.assertEqual(result['statusCode'], 400)
        result = self.request('alice', 'POST /v1/me/pet/trips', {})
        self.assertEqual(result['statusCode'], 404)
        for saving in [-1, float('nan'), float('inf'), True, '5']:
            with self.assertRaises(PetError):
                self.service.credit_trip('alice', 'bad-trip', saving)

    def test_catalogue_is_authenticated(self):
        result = self.request('alice', 'GET /v1/me/pet/catalogue')
        self.assertEqual(result['statusCode'], 200)
        catalogue = json.loads(result['body'])
        self.assertEqual(catalogue['pets']['koala'], 5)
        self.assertEqual(catalogue['items']['water']['price'], 5)


if __name__ == '__main__':
    unittest.main()

import json
import os

import boto3
from botocore.exceptions import ClientError

from service import Conflict


class PetStore:
    def __init__(self, table_name=None, client=None):
        self.table = table_name or os.environ['PETS_TABLE']
        self.client = client or boto3.client('dynamodb')

    @staticmethod
    def _key(owner, record):
        return {'owner': {'S': owner}, 'record': {'S': record}}

    def _read(self, owner, record):
        response = self.client.get_item(
            TableName=self.table, Key=self._key(owner, record),
            ConsistentRead=True,
        )
        item = response.get('Item')
        return json.loads(item['payload']['S']) if item else None

    def load(self, owner):
        return self._read(owner, 'state')

    def receipt(self, owner, key):
        return self._read(owner, key)

    def create(self, owner, state):
        item = self._key(owner, 'state')
        item.update({'version': {'N': '0'}, 'payload': {'S': json.dumps(state)}})
        try:
            self.client.put_item(
                TableName=self.table, Item=item,
                ConditionExpression='attribute_not_exists(#owner)',
                ExpressionAttributeNames={'#owner': 'owner'},
            )
        except ClientError as error:
            if error.response['Error']['Code'] != 'ConditionalCheckFailedException':
                raise

    def commit(self, owner, version, state, key, fingerprint, result):
        item = self._key(owner, 'state')
        item.update({'version': {'N': str(state['version'])},
                     'payload': {'S': json.dumps(state, allow_nan=False)}})
        receipt = self._key(owner, key)
        receipt['payload'] = {'S': json.dumps({
            'fingerprint': fingerprint, 'result': result,
        }, allow_nan=False)}
        try:
            self.client.transact_write_items(TransactItems=[
                {'Put': {
                    'TableName': self.table, 'Item': item,
                    'ConditionExpression': '#version = :version',
                    'ExpressionAttributeNames': {'#version': 'version'},
                    'ExpressionAttributeValues': {':version': {'N': str(version)}},
                }},
                {'Put': {
                    'TableName': self.table, 'Item': receipt,
                    'ConditionExpression': 'attribute_not_exists(#owner)',
                    'ExpressionAttributeNames': {'#owner': 'owner'},
                }},
            ])
        except ClientError as error:
            if error.response['Error']['Code'] == 'TransactionCanceledException':
                reasons = error.response.get('CancellationReasons', [])
                if any(reason.get('Code') in ('ConditionalCheckFailed', 'TransactionConflict')
                       for reason in reasons):
                    raise Conflict() from error
            raise

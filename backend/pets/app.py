import base64
import json
import logging

from catalogue import ACTIONS, ITEMS, PET_UNLOCKS
from service import PetError, PetService
from store import PetStore

logger = logging.getLogger(__name__)


def response(status, body):
    return {
        'statusCode': status,
        'headers': {'Content-Type': 'application/json', 'Cache-Control': 'no-store'},
        'body': json.dumps(body, allow_nan=False),
    }


def handle_request(event, service):
    claims = event.get('requestContext', {}).get('authorizer', {}).get('jwt', {}).get('claims', {})
    owner = claims.get('sub')
    if not isinstance(owner, str) or not owner or claims.get('token_use') != 'access':
        return response(401, {'code': 'unauthorized', 'message': 'Sign in first'})
    route = event.get('routeKey')
    try:
        if route == 'GET /v1/me/pet':
            return response(200, service.read(owner))
        if route == 'GET /v1/me/pet/catalogue':
            return response(200, {'pets': PET_UNLOCKS, 'items': ITEMS, 'actions': ACTIONS})
        operation = {
            'PUT /v1/me/pet/selection': 'selection',
            'PUT /v1/me/pet/equipment': 'equipment',
            'POST /v1/me/pet/purchases': 'purchases',
            'POST /v1/me/pet/actions': 'actions',
        }.get(route)
        if operation is None:
            return response(404, {'code': 'not_found', 'message': 'Unknown route'})
        raw = event.get('body') or ''
        if event.get('isBase64Encoded'):
            raw = base64.b64decode(raw, validate=True).decode('utf-8')
        body = json.loads(raw)
        if not isinstance(body, dict):
            raise ValueError('Expected an object')
        return response(200, service.mutate(owner, operation, body))
    except PetError as error:
        return response(error.status, {'code': error.code, 'message': str(error)})
    except (ValueError, TypeError, UnicodeError):
        return response(400, {'code': 'invalid_body', 'message': 'Invalid request body'})


def handler(event, context):
    try:
        return handle_request(event, PetService(PetStore()))
    except Exception:
        logger.exception('Pets request failed')
        return response(500, {'code': 'server_error', 'message': 'Please try again later'})


def credit_trip_handler(event, context):
    return PetService(PetStore()).credit_trip(
        event['owner'], event['trip_id'], event['co2_saved_kg'],
    )
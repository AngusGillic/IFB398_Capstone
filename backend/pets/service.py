import copy
import hashlib
import json
from datetime import datetime, timezone
from decimal import Decimal
from uuid import UUID

from catalogue import ACTIONS, COINS_PER_KG, ITEMS, PET_UNLOCKS


class PetError(Exception):
    def __init__(self, code, message, status=409):
        super().__init__(message)
        self.code = code
        self.status = status


class Conflict(Exception):
    pass


def new_pet(now):
    return {
        'adopted_at': now.isoformat().replace('+00:00', 'Z'),
        'happiness': 1.0, 'energy': 1.0, 'health': 1.0,
        'cooldowns': {},
    }


def new_state(now):
    return {
        'selected_pet_id': 'puppy', 'coins': 0, 'inventory': {},
        'co2_saved_kg': 0.0, 'version': 0,
        'pets': {'puppy': new_pet(now)},
    }


def snapshot(state, now):
    pet = state['pets'][state['selected_pet_id']]
    adopted = datetime.fromisoformat(pet['adopted_at'].replace('Z', '+00:00'))
    return {
        'selected_pet_id': state['selected_pet_id'],
        'adopted_at': pet['adopted_at'],
        'pet': {
            'coins': state['coins'],
            'happiness': pet['happiness'], 'energy': pet['energy'],
            'health': pet['health'],
            'days_together': max(0, (now - adopted).days),
        },
        'inventory': copy.deepcopy(state['inventory']),
        'co2_saved_kg': state['co2_saved_kg'], 'version': state['version'],
        'server_time': now.isoformat().replace('+00:00', 'Z'),
        'cooldowns': {
            action: datetime.fromtimestamp(until, timezone.utc).isoformat().replace('+00:00', 'Z')
            for action, until in pet['cooldowns'].items() if until > now.timestamp()
        },
    }


class PetService:
    def __init__(self, store, clock=None):
        self.store = store
        self.clock = clock or (lambda: datetime.now(timezone.utc))

    def _load(self, owner, now):
        state = self.store.load(owner)
        if state is None:
            self.store.create(owner, new_state(now))
            state = self.store.load(owner)
        return state

    def read(self, owner):
        now = self.clock()
        return snapshot(self._load(owner, now), now)

    def mutate(self, owner, operation, body):
        field = {'selection': 'pet_id', 'purchases': 'item_id',
                 'actions': 'action_id'}.get(operation)
        if field is None:
            raise PetError('not_found', 'Unknown operation', 404)
        if set(body) != {field, 'version', 'request_id'}:
            raise PetError('invalid_body', 'Unexpected or missing fields', 400)
        if type(body['version']) is not int or body['version'] < 0:
            raise PetError('invalid_body', 'Version must be a whole number', 400)
        if not isinstance(body[field], str):
            raise PetError('invalid_body', 'Invalid selection or action', 400)
        try:
            request_id = str(UUID(body['request_id']))
        except (ValueError, TypeError, AttributeError):
            raise PetError('invalid_body', 'Request ID must be a UUID', 400)

        key = 'request:' + request_id
        fingerprint = self._fingerprint(operation, body)
        previous = self._previous(owner, key, fingerprint)
        if previous is not None:
            return previous
        now = self.clock()
        state = self._load(owner, now)
        if state['version'] != body['version']:
            raise PetError('stale_version', 'Reload your pet and try again')
        updated = copy.deepcopy(state)
        self._apply(updated, operation, body[field], now)
        updated['version'] += 1
        result = snapshot(updated, now)
        try:
            self.store.commit(owner, state['version'], updated, key,
                              fingerprint, result)
        except Conflict:
            previous = self._previous(owner, key, fingerprint)
            if previous is not None:
                return previous
            raise PetError('stale_version', 'Reload your pet and try again')
        return result

    def _apply(self, state, operation, value, now):
        if operation == 'selection':
            if value not in PET_UNLOCKS:
                raise PetError('unknown_pet', 'Unknown pet', 400)
            if state['co2_saved_kg'] < PET_UNLOCKS[value]:
                raise PetError('pet_locked', 'This pet is still locked')
            state['pets'].setdefault(value, new_pet(now))
            state['selected_pet_id'] = value
            return

        if operation == 'purchases':
            item = ITEMS.get(value)
            if item is None:
                raise PetError('unknown_item', 'Unknown garden item', 400)
            quantity = state['inventory'].get(value, 0)
            if item['durable'] and quantity:
                raise PetError('already_owned', 'You already own this item')
            if state['coins'] < item['price']:
                raise PetError('insufficient_coins', 'Not enough coins')
            state['coins'] -= item['price']
            state['inventory'][value] = quantity + 1
            return

        action = ACTIONS.get(value)
        if action is None:
            raise PetError('unknown_action', 'Unknown care action', 400)
        pet = state['pets'][state['selected_pet_id']]
        if pet['cooldowns'].get(value, 0) > now.timestamp():
            raise PetError('cooldown', 'This action is not ready yet')
        item = action.get('item')
        if item:
            quantity = state['inventory'].get(item, 0)
            if quantity < 1:
                raise PetError('missing_inventory', 'Buy this item first')
            state['inventory'][item] = quantity - 1
        for stat, amount in action['effects'].items():
            pet[stat] = min(1.0, max(0.0, round(pet[stat] + amount, 6)))
        if 'cooldown_seconds' in action:
            pet['cooldowns'][value] = now.timestamp() + action['cooldown_seconds']

    # Called by the trusted trip worker, never by a client route.
    def credit_trip(self, owner, trip_id, saved_kg):
        if not isinstance(trip_id, str) or not 1 <= len(trip_id) <= 128:
            raise PetError('invalid_trip', 'Invalid trip ID', 400)
        if type(saved_kg) not in (int, float, Decimal):
            raise PetError('invalid_trip', 'Invalid saving', 400)
        saved = Decimal(str(saved_kg))
        if not saved.is_finite() or saved < 0 or saved > 1000:
            raise PetError('invalid_trip', 'Invalid saving', 400)
        body = {'trip_id': trip_id, 'saved_kg': str(saved.normalize())}
        fingerprint = self._fingerprint('trip', body)
        key = 'trip:' + trip_id
        for _ in range(3):
            previous = self._previous(owner, key, fingerprint)
            if previous is not None:
                return previous
            now = self.clock()
            state = self._load(owner, now)
            updated = copy.deepcopy(state)
            updated['co2_saved_kg'] = float(Decimal(str(state['co2_saved_kg'])) + saved)
            updated['coins'] += int(saved * COINS_PER_KG)
            updated['version'] += 1
            result = snapshot(updated, now)
            try:
                self.store.commit(owner, state['version'], updated, key,
                                  fingerprint, result)
                return result
            except Conflict:
                continue
        raise PetError('stale_version', 'Trip credit needs retrying')

    def _previous(self, owner, key, fingerprint):
        receipt = self.store.receipt(owner, key)
        if receipt is None:
            return None
        if receipt['fingerprint'] != fingerprint:
            raise PetError('request_conflict', 'Request ID was already used')
        return receipt['result']

    @staticmethod
    def _fingerprint(operation, body):
        payload = json.dumps([operation, body], sort_keys=True, allow_nan=False)
        return hashlib.sha256(payload.encode()).hexdigest()

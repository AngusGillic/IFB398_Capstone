import copy
import hashlib
import json
from datetime import datetime, timezone
from decimal import Decimal
from uuid import UUID

from catalogue import ACTIONS, CARE_DECAY_PER_HOUR, COINS_PER_KG, ITEMS, PET_UNLOCKS


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
        'happiness': 0.75, 'energy': 0.65, 'health': 0.8,
        'updated_at': now.isoformat().replace('+00:00', 'Z'),
        'cooldowns': {},
    }


def new_state(now):
    return {
        'selected_pet_id': 'puppy', 'coins': 0, 'inventory': {},
        'equipped': {
            'room': 'room1',
            'rug': 'grassrug',
            'plant': None,
            'left': None,
            'top_right': None,
        },
        'co2_saved_kg': 0.0, 'version': 0,
        'pets': {'puppy': new_pet(now)},
    }


def progress(state, now):
    updated = copy.deepcopy(state)
    for pet in updated['pets'].values():
        last = datetime.fromisoformat(pet.get('updated_at', pet['adopted_at']).replace('Z', '+00:00'))
        hours = max(0, (now - last).total_seconds() / 3600)
        rates = dict(CARE_DECAY_PER_HOUR)
        if updated['inventory'].get('small_pot', 0):
            rates['happiness'] *= 0.5
        if updated['inventory'].get('kennel', 0):
            rates['energy'] *= 0.5
        for stat, rate in rates.items():
            pet[stat] = max(0.0, round(pet[stat] - hours * rate, 6))
        pet['updated_at'] = max(last, now).isoformat().replace('+00:00', 'Z')
    return updated


def snapshot(state, now):
    state = progress(state, now)
    pet = state['pets'][state['selected_pet_id']]
    adopted = datetime.fromisoformat(pet['adopted_at'].replace('Z', '+00:00'))
    equipped = state.get('equipped', {
        'room': 'room1',
        'rug': 'grassrug',
        'plant': None,
        'left': None,
        'top_right': None,
    })
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
        'equipped': copy.deepcopy(equipped),
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
        field = {'selection': 'pet_id', 'equipment': 'item_id',
                 'purchases': 'item_id', 'actions': 'action_id'}.get(operation)
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
        updated = progress(state, now)
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

        if operation == 'equipment':
            slots = {
                # Background
                'room1': 'room',
                'room2': 'room',
                'room3': 'room',

                # Rugs
                'grassrug': 'rug',
                'flowerrug': 'rug',
                'pinkrug': 'rug',

                # Plants
                'plant1': 'plant',
                'plant2': 'plant',
                'plant3': 'plant',
                'plant4': 'plant',
                'plant5': 'plant',

                # Left slot
                'house1': 'left',
                'house2': 'left',
                'house3': 'left',
                'petbed': 'left',

                # Top-right slot
                'cattree': 'top_right',
                'lamp1': 'top_right',
                'lamp2': 'top_right',
            }

            slot = slots.get(value)

            if slot is None:
                raise PetError('not_equippable', 'This item cannot be equipped', 400)

            # Free/default items don't need to be purchased.
            free_items = {'room1', 'grassrug'}

            if value not in free_items and state['inventory'].get(value, 0) < 1:
                raise PetError('not_owned', 'You do not own this item')

            state.setdefault('equipped', {
                'room': 'room1',
                'rug': 'grassrug',
                'plant': None,
                'left': None,
                'top_right': None,
            })

            state['equipped'][slot] = value
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
        if all(pet[stat] >= 1.0 for stat in action['effects']):
            raise PetError('care_not_needed', 'Your pet does not need this care yet', 422)
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
            updated = progress(state, now)
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
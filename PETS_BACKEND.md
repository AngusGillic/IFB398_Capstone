# Pets backend

The Pets screens currently read stats from `AppData` and selection from
`PetController`. `PetState` is the response model for the proposed Pets API.
It reuses `PetStats`, so the existing profile and garden can keep their data
structure when the API is connected.

## State

All successful requests below return this complete snapshot:

```json
{
  "selected_pet_id": "puppy",
  "adopted_at": "2026-10-13T00:00:00Z",
  "pet": {
    "coins": 0,
    "happiness": 1.0,
    "energy": 1.0,
    "health": 1.0,
    "days_together": 0
  },
  "inventory": {},
  "co2_saved_kg": 0.0,
  "version": 0,
  "server_time": "2026-10-13T00:00:00Z",
  "cooldowns": {}
}
```

Dates use UTC. Ratios are between 0 and 1, coins and quantities are
non-negative whole numbers. `co2_saved_kg` is the user's lifetime total.
`version` increases after each mutation. The server computes days together
from the adoption date, rather than accepting it from the client.

The first read creates a starter pet if no record exists. Initial stats above
are the proposed defaults. Switching pets keeps the account's coins and
inventory, restores that pet's original adoption date and saved care stats.
Inventory belongs to the account; care stats and adoption dates belong to each
pet. The response describes the currently selected pet.

## Requests

Paths are relative to a configurable Pets API base URL. All requests require
an `Authorization: Bearer <Cognito access token>` header. The backend verifies
the token and uses its subject as the owner; it never accepts a client user ID.

| Method | Path | Body | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/me/pet` | None | Load or initialise state |
| GET | `/v1/me/pet/catalogue` | None | Read unlocks, prices and care effects |
| PUT | `/v1/me/pet/selection` | `{"pet_id":"koala","version":0,"request_id":"uuid"}` | Select an unlocked pet |
| POST | `/v1/me/pet/purchases` | `{"item_id":"water","version":1,"request_id":"uuid"}` | Buy one garden item |
| POST | `/v1/me/pet/actions` | `{"action_id":"water","version":2,"request_id":"uuid"}` | Use an owned item or perform care |

The server owns the pet catalogue, unlock thresholds, item prices and care
effects. It validates selection against actual lifetime savings. Clients
cannot set coins, stats, prices, unlocks or inventory directly. Reward credits
come from verified trips, with each trip credited once.

Purchases deduct coins and add inventory atomically. Care consumes applicable
inventory and updates stats atomically, clamped to 0 through 1. Small pot and
kennel are durable items; water and fertiliser are consumables. Sunlight is a
care action with a server-controlled cooldown. More opens the item catalogue
and is not a mutation. Prices, effects and cooldown durations are provisional
defaults in `backend/pets/catalogue.py`. They need review
before deployment; the current UI does not define them.

Each mutation uses a unique request ID. Retrying the same request returns its
original result without charging or applying it again. Reusing an ID with a
different body fails. The version check and write happen in one transaction;
a stale version returns a conflict so the client can reload before retrying.

## Errors

Errors return `{"code":"pet_locked","message":"This pet is still locked"}`.

- `400`: invalid body, unknown item, action or pet.
- `401`: missing or invalid authentication.
- `409`: stale version, insufficient coins, missing inventory, owned durable
  item, locked pet, cooldown or conflicting request ID.
- `500`: unexpected server failure; keep the client's last confirmed state.

## Integration

Step two adds the server implementation and storage under `backend/`.
Step three adds an API service under `lib/services/`, loads state after sign-in and clears it on
sign-out. It publishes confirmed stats to `AppData` and selection to
`PetController`. Pet selection and profile should listen for state updates.
Step four connects the garden actions and shows pending/error states. No
screen should predict a successful purchase or permanently alter coins before
the server confirms it.

The server implementation and deployment template are under `backend/`.
Deployment is outside the current scope. Selection and profile now load
confirmed Pets data from the configured API.


## Implementation plan

1. Define the response model and API contract for selection, care stats and
   garden inventory. Complete.
2. Implement authenticated storage and endpoints with owner isolation,
   authoritative unlock checks, transactions and request deduplication.
   Implemented locally; deployment and the external trips-worker hookup
   are pending.
3. Connect selection and profile to the API; handle loading, failures,
   relaunches and account changes. Complete.
4. Implement garden purchases and care actions, including inventory, prices,
   effects and cooldowns. Complete.
5. Verify the complete flow with backend and client tests for unlocks, rewards,
   retries, concurrent updates and account isolation. Complete locally.


## Flutter client

Set the existing Pets API base URL when running the app:

```powershell
flutter run --dart-define=PETS_API_URL=https://your-pets-api.example
```

`PetApi` attaches the current Cognito access token and checks that its account
matches the owner bound to `PetData`. The owner is never sent in the request
body or URL. `PetData` discards responses from a previous account, clears state
on sign-out, and publishes only confirmed snapshots. A lost mutation response
retains its original request ID for retry; conflicting writes reload the
server state before the user tries again. Missing configuration displays an
unavailable state instead of showing mock stats.

Selection waits for a successful write before opening the garden. Profile
listens for updated care stats. Confirmed pet stats and lifetime savings also
update `AppData`; loading the existing summary cannot replace them with its
hardcoded figures.


## Garden actions

The garden loads prices and available actions from the server catalogue.
Item menus show the current balance and owned quantities. Purchases require
confirmation; water and fertiliser can be used from that menu when owned.
Small pots and kennels appear in the garden after a confirmed purchase. More
opens the catalogue. Pending or unresolved writes disable further actions
until they complete or their original request is retried.

Snapshots include `server_time` and a `cooldowns` map of action IDs to UTC
expiry dates. The client measures elapsed time from the response, so a device
clock offset does not unlock sunlight early. The server still enforces the
cooldown. After retrying an uncertain write, the client reads fresh state to
avoid treating an old receipt as the current balance or cooldown. Catalogue
failures disable garden actions and provide a separate reload button.

AWS deployment remains outside the current scope.


## Final verification

The local suite covers the full client-to-server JSON flow over loopback HTTP,
using the production Pets handlers and simulated DynamoDB. It verifies trip
credits and unlocks, selection, purchases, care, relaunch persistence, separate
accounts, competing writes and a committed purchase whose response is lost.
The fixture supplies test identity claims; live Cognito verification and
external trips-worker wiring are not part of this local suite.

Final regression fixes clear personal data on non-JSON authentication errors,
block further writes when a conflict refresh fails, and discard responses
received after the client is disposed. Shared test data is in `test/support/`.

The final run passed 32 Dart/client/UI/integration tests and 15 backend checks.
The existing external trips worker still needs to invoke the prepared reward
hook. Deployment remains outside the requested scope.

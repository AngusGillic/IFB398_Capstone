# Pets server

This adds a standalone Lambda/DynamoDB backend alongside the Flutter app. It
uses the existing Cognito user pool and app client, supplied at deployment.
No AWS resources have been created by this change.

## User ownership

API Gateway verifies the Cognito access token. The handler reads `sub` from
Gateway's verified claims and rejects ID tokens. All table reads and writes
use that subject as the partition key. Each user's state, request receipts and
trip receipts are kept in their own partition. Request bodies cannot choose
an owner, set balances or grant unlocks.

Each mutation writes the updated state and its receipt in one DynamoDB
transaction. A version condition prevents lost updates; the receipt prevents
repeat charges. Receipts are retained so even an old retry cannot apply twice.
Selecting a pet restores that user's saved stats and original adoption date
for that pet. Coins and garden inventory are shared across their own pets.

The authorizer and transactions follow the AWS documentation:
[JWT authorizers](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-jwt-authorizer.html),
[SAM authorizers](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-controlling-access-to-apis-oauth2-authorizer.html),
[DynamoDB transactions](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TransactWriteItems.html).

## Development

From the repository root:

```powershell
python -m venv backend/.venv
backend/.venv/Scripts/python -m pip install -r backend/requirements-test.txt
backend/.venv/Scripts/python -m unittest discover -s backend/tests -v
```

Tests use Moto's simulated AWS services, not a live table or account. The
SAM translator checks the deployment template locally. A live deployment
still needs a smoke test with genuine Cognito tokens from two accounts.

## Deployment

Install the AWS SAM CLI, then run from `backend/` when deployment is approved:

```powershell
sam build
sam deploy --guided --region ap-southeast-2
```

Supply the existing Cognito pool ID, app client ID and the Flutter web origin.
The user pool must be in the deployment region. Direct Cognito sign-in access
tokens must include `aws.cognito.signin.user.admin`; an OAuth sign-in flow
must request that scope. The template creates the API, two Lambda functions,
an encrypted table with point-in-time recovery, and a role limited to reading
and writing that table plus Lambda logs. The table is retained on deletion.
There are no hardcoded credentials or replacement authentication resources.

The `PetsApiUrl` output is the base URL for step three. All Pets routes are
protected, including `GET /v1/me/pet/catalogue`. This route returns server
unlock thresholds, prices, item durability, care effects and cooldowns.

## Trip rewards

`TripCreditFunction` has no API route or public invocation permission. Grant
only the trusted trips worker permission to invoke its output ARN. After a
trip is verified and saved, that worker sends:

```json
{"owner":"cognito-sub","trip_id":"durable-trip-id","co2_saved_kg":0.8}
```

The worker must obtain the owner and saving from its verified trip record,
not forward client-supplied values. Retries must reuse the same trip ID and
saving. A trip is credited once per user; a changed saving for the same trip
is rejected. Conflicts can be retried with the same event. The handler raises
on failure so the worker can retry or queue it; configure a dead-letter queue
if using asynchronous Lambda invocation.

The current trips server is outside this repository, so this hook is not
connected yet. Existing trip history needs replaying through the same trusted
worker with the original trip IDs before lifetime unlocks reflect past trips.
Do not send the hardcoded Flutter lifetime total to this handler.

## Provisional game values

`pets/catalogue.py` holds all game values. Water costs 5 coins, fertiliser 10,
a small pot 25 and a kennel 50. Sunlight is free with a one-hour cooldown.
Water and fertiliser are consumed; pots and kennels can be bought once.
Verified trips earn 10 coins per kg saved, rounded down per trip. New pets
start with 75% happiness, 65% energy and 80% health so care has an immediate effect.
These are implementation defaults for review, not values found in the UI.
Small pot and kennel purchases save ownership; displaying them is step four.

Selection and profile use the configured Pets API. See `../PETS_BACKEND.md`
for the Flutter configuration. Garden purchases, care actions, ownership displays and sunlight cooldowns
are also connected. Deployment remains outside the current scope.


## Client integration checks

After installing the test dependencies above, run from the repository root:

```powershell
flutter pub get
$env:PETS_TEST_PYTHON = (Resolve-Path backend/.venv/Scripts/python.exe).Path
flutter test --no-pub test/pet_state_test.dart test/pet_data_test.dart test/pet_pages_test.dart test/pet_garden_test.dart test/pet_integration_test.dart
```

The integration file starts a temporary loopback server from
`tests/pets_server.py`, calls the production handlers against simulated
DynamoDB, and stops the server on completion. Its test-only trip-credit and
response-loss controls are not included in the Lambda package. No deployed
AWS services or genuine user credentials are used. Authentication is covered
by handler checks and the template tests, rather than live Cognito sign-in.

The fixtures under `test/support/` are shared by the client and UI tests. The
local suite passed 36 Dart tests and 20 backend checks.


## Care progression

The server projects condition from each pet's last saved timestamp, including
while the app is closed. Each hour loses 2 percentage points of happiness,
4 of energy and 1 of health, bounded at zero. Reads do not repeatedly subtract
the same elapsed time. Mutations settle elapsed decay before applying changes.
Existing pets use their adoption date when no care timestamp is stored.

Water adds 10 health and 5 happiness points; fertiliser adds 20 health points;
sunlight adds 15 energy points with a one-hour cooldown. Stats are capped at
100%. Care with no benefit is rejected without consuming an item. A small pot
halves future happiness loss; a kennel halves future energy loss. Each pet
keeps its own condition, while inventory stays shared within the account.
The garden displays condition and refreshes saved state every minute.

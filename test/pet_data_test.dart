import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travelly_flutter_ios_style/core/pet_data.dart';
import 'package:travelly_flutter_ios_style/data/user_data.dart';
import 'package:travelly_flutter_ios_style/models/pet.dart';
import 'package:travelly_flutter_ios_style/services/pet_api.dart';

import 'support/pet_fixtures.dart';

void main() {
  test(
    'Loads saved selection with an access token and no client owner field',
    () async {
      final owners = <String>[];
      final pets = petsWith(
        (request) async {
          expect(request.url.path, '/v1/me/pet');
          expect(request.url.query, isEmpty);
          expect(request.headers['Authorization'], 'Bearer token-alice');
          return http.Response(jsonEncode(petResponse(pet: 'koala')), 200);
        },
        ownerUsed: owners.add,
        publish: true,
      );
      addTearDown(() {
        AppData.instance.reset();
        PetController.instance.select('puppy');
      });
      pets.bindUser('alice');
      await pets.load();
      expect(owners, ['alice']);
      expect(pets.value!.selectedPetId, 'koala');
      expect(AppData.current.pet.coins, 20);
      expect(AppData.current.lifetime.co2SavedKg, 10);
      expect(PetController.instance.value, 'koala');
    },
  );

  test('Selection waits for the server and ignores duplicate taps', () async {
    final response = Completer<http.Response>();
    var writes = 0;
    final pets = petsWith((request) async {
      if (request.method == 'GET')
        return http.Response(jsonEncode(petResponse()), 200);
      writes++;
      expect(request.method, 'PUT');
      expect(request.url.path, '/v1/me/pet/selection');
      expect(jsonDecode(request.body)['pet_id'], 'koala');
      expect(
        jsonDecode(request.body).keys,
        unorderedEquals(['pet_id', 'version', 'request_id']),
      );
      return response.future;
    });
    pets.bindUser('alice');
    await pets.load();
    final selection = pets.select('koala');
    expect(pets.value!.selectedPetId, 'puppy');
    expect(pets.busy, isTrue);
    expect(await pets.select('koala'), isFalse);
    response.complete(
      http.Response(jsonEncode(petResponse(pet: 'koala', version: 1)), 200),
    );
    expect(await selection, isTrue);
    expect(writes, 1);
    expect(pets.value!.selectedPetId, 'koala');
  });

  test('Late reads from a previous account are discarded', () async {
    final alice = Completer<http.Response>();
    final pets = petsWith((request) async {
      if (request.headers['Authorization'] == 'Bearer token-alice')
        return alice.future;
      return http.Response(jsonEncode(petResponse(coins: 7)), 200);
    });
    pets.bindUser('alice');
    final oldRead = pets.load();
    pets.bindUser('bob');
    expect(pets.value, isNull);
    await pets.load();
    alice.complete(
      http.Response(jsonEncode(petResponse(pet: 'koala', coins: 100)), 200),
    );
    await oldRead;
    expect(pets.owner, 'bob');
    expect(pets.value!.stats.coins, 7);
    expect(pets.value!.selectedPetId, 'puppy');
  });

  test(
    'Sign-out discards a late selection response and its pending retry',
    () async {
      final reply = Completer<http.Response>();
      final pets = petsWith(
        (request) async => request.method == 'GET'
            ? http.Response(jsonEncode(petResponse()), 200)
            : reply.future,
      );
      pets.bindUser('alice');
      await pets.load();
      final selection = pets.select('koala');
      pets.bindUser(null);
      reply.complete(
        http.Response(jsonEncode(petResponse(pet: 'koala', version: 1)), 200),
      );
      expect(await selection, isFalse);
      expect(pets.value, isNull);
      expect(pets.signedIn, isFalse);
      expect(pets.needsRetry, isFalse);
      expect(pets.busy, isFalse);
    },
  );

  test(
    'A lost response retries the same mutation without changing the pet early',
    () async {
      final bodies = <String>[];
      final pets = petsWith((request) async {
        if (request.method == 'GET')
          return http.Response(jsonEncode(petResponse()), 200);
        bodies.add(request.body);
        if (bodies.length == 1) throw http.ClientException('Lost response');
        return http.Response(
          jsonEncode(petResponse(pet: 'koala', version: 1)),
          200,
        );
      });
      pets.bindUser('alice');
      await pets.load();
      expect(await pets.select('koala'), isFalse);
      expect(pets.needsRetry, isTrue);
      expect(pets.value!.selectedPetId, 'puppy');
      expect(await pets.select('frill'), isFalse);
      expect(await pets.retry(), isTrue);
      expect(bodies[0], bodies[1]);
      expect(pets.needsRetry, isFalse);
    },
  );

  test(
    'A conflict reloads confirmed state and allows another attempt',
    () async {
      var reads = 0;
      final pets = petsWith((request) async {
        if (request.method == 'GET') {
          reads++;
          return http.Response(
            jsonEncode(petResponse(version: reads - 1)),
            200,
          );
        }
        return http.Response(
          jsonEncode({'code': 'stale_version', 'message': 'Reload your pet'}),
          409,
        );
      });
      pets.bindUser('alice');
      await pets.load();
      expect(await pets.select('koala'), isFalse);
      expect(pets.value!.version, 1);
      expect(pets.value!.selectedPetId, 'puppy');
      expect(pets.needsRetry, isFalse);
      expect(pets.error, 'Reload your pet');
    },
  );

  test('An expired session clears confirmed personal data', () async {
    var expired = false;
    final pets = petsWith(
      (request) async => expired
          ? http.Response('{"message":"Sign in again"}', 401)
          : http.Response(jsonEncode(petResponse(pet: 'koala')), 200),
    );
    pets.bindUser('alice');
    await pets.load();
    expired = true;
    await pets.load();
    expect(pets.value, isNull);
    expect(pets.signedIn, isFalse);
    expect(pets.busy, isFalse);
  });

  test('Non-JSON authentication errors clear personal state', () async {
    var expired = false;
    final pets = petsWith(
      (_) async => expired
          ? http.Response('Unauthorized', 401)
          : http.Response(jsonEncode(petResponse(pet: 'koala')), 200),
    );
    pets.bindUser('alice');
    await pets.load();
    expired = true;
    await pets.load();
    expect(pets.value, isNull);
    expect(pets.signedIn, isFalse);
  });

  test(
    'A failed conflict refresh blocks writes until fresh state is loaded',
    () async {
      var reads = 0;
      var writes = 0;
      var offline = true;
      final pets = petsWith((request) async {
        if (request.method == 'GET') {
          reads++;
          if (reads > 1 && offline) throw http.ClientException('Offline');
          return http.Response(
            jsonEncode(petResponse(version: reads > 1 ? 1 : 0)),
            200,
          );
        }
        writes++;
        return http.Response(
          '{"code":"stale_version","message":"Reload your pet"}',
          409,
        );
      });
      pets.bindUser('alice');
      await pets.load();
      expect(await pets.select('koala'), isFalse);
      expect(pets.needsRefresh, isTrue);
      expect(await pets.select('frill'), isFalse);
      expect(writes, 1);
      offline = false;
      await pets.load();
      expect(pets.needsRefresh, isFalse);
      expect(pets.value!.version, 1);
    },
  );

  test(
    'Authentication expiry during conflict recovery clears the old account',
    () async {
      var reads = 0;
      final pets = petsWith((request) async {
        if (request.method == 'GET') {
          reads++;
          return reads == 1
              ? http.Response(jsonEncode(petResponse()), 200)
              : http.Response('Unauthorized', 401);
        }
        return http.Response(
          '{"code":"stale_version","message":"Reload your pet"}',
          409,
        );
      });
      pets.bindUser('alice');
      await pets.load();
      expect(await pets.select('koala'), isFalse);
      expect(pets.signedIn, isFalse);
      expect(pets.value, isNull);
    },
  );

  test('Disposing an in-flight client discards its response', () async {
    final response = Completer<http.Response>();
    final client = MockClient((_) => response.future);
    addTearDown(client.close);
    var published = false;
    final pets = PetData(
      api: PetApi(
        client: client,
        baseUrl: 'https://pets.example',
        accessToken: (_) async => 'token',
      ),
      onChanged: (_) => published = true,
      onCleared: () {},
    );
    pets.bindUser('alice');
    final loading = pets.load();
    pets.dispose();
    response.complete(http.Response(jsonEncode(petResponse()), 200));
    await loading;
    expect(published, isFalse);
  });

  test('Missing configuration fails without making a request', () async {
    var requested = false;
    final client = MockClient((_) async {
      requested = true;
      return http.Response('{}', 200);
    });
    addTearDown(client.close);
    final pets = PetData(
      api: PetApi(
        client: client,
        baseUrl: '',
        accessToken: (_) async => 'token',
      ),
      onChanged: (_) {},
    );
    addTearDown(pets.dispose);
    pets.bindUser('alice');
    await pets.load();
    expect(requested, isFalse);
    expect(pets.value, isNull);
    expect(pets.error, 'Pets are unavailable right now.');
  });
}

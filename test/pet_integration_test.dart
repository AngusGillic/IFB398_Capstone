import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travelly_flutter_ios_style/core/pet_data.dart';
import 'package:travelly_flutter_ios_style/services/pet_api.dart';

void main() {
  late Process server;
  late int port;
  late http.Client network;

  setUpAll(() async {
    final python =
        Platform.environment['PETS_TEST_PYTHON'] ??
        (Platform.isWindows
            ? 'backend/.venv/Scripts/python.exe'
            : 'backend/.venv/bin/python');
    server = await Process.start(python, [
      '-u',
      'backend/tests/pets_server.py',
    ]);
    server.stderr
        .transform(utf8.decoder)
        .listen((message) => stderr.write(message));
    final line = await server.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .first
        .timeout(const Duration(seconds: 20));
    port = (jsonDecode(line) as Map<String, dynamic>)['port'] as int;
    network = http.Client();
  });

  tearDownAll(() async {
    try {
      await network
          .post(
            Uri.http('127.0.0.1:$port', '/_test/shutdown'),
            headers: {'Authorization': 'Bearer fixture-admin'},
          )
          .timeout(const Duration(seconds: 5));
      await server.exitCode.timeout(const Duration(seconds: 5));
    } finally {
      network.close();
      server.kill();
    }
  });

  PetData clientFor(String owner, {bool losePurchaseResponse = false}) {
    var loseNext = losePurchaseResponse;
    final adapter = MockClient((request) async {
      final forwarded = http.Request(
        request.method,
        Uri.http('127.0.0.1:$port', request.url.path),
      );
      forwarded.headers.addAll(request.headers);
      forwarded.bodyBytes = request.bodyBytes;
      if (loseNext && request.url.path.endsWith('/purchases')) {
        loseNext = false;
        forwarded.headers['X-Test-Drop-Response'] = '1';
      }
      return http.Response.fromStream(await network.send(forwarded));
    });
    addTearDown(adapter.close);
    final data = PetData(
      api: PetApi(
        client: adapter,
        baseUrl: 'https://fixture.example',
        accessToken: (boundOwner) async {
          expect(boundOwner, owner);
          return 'fixture-$owner';
        },
      ),
      onChanged: (_) {},
      onCleared: () {},
    );
    data.bindUser(owner);
    addTearDown(data.dispose);
    return data;
  }

  Future<void> credit(String owner, String tripId, double saving) async {
    final response = await network.post(
      Uri.http('127.0.0.1:$port', '/_test/trips'),
      headers: {
        'Authorization': 'Bearer fixture-admin',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'owner': owner,
        'trip_id': tripId,
        'co2_saved_kg': saving,
      }),
    );
    expect(response.statusCode, 200);
  }

  test(
    'Trips, unlocks, purchases and care survive relaunch and stay per account',
    () async {
      final alice = clientFor('alice');
      await alice.load();
      expect(alice.value!.stats.coins, 0);
      expect(await alice.select('koala'), isFalse);
      await credit('alice', 'trip-1', 5);
      await credit('alice', 'trip-1', 5);
      await alice.load();
      await alice.loadShop();
      expect(alice.value!.stats.coins, 50);
      expect(alice.value!.co2SavedKg, 5);
      expect(await alice.select('koala'), isTrue);
      expect(await alice.buy('water'), isTrue);
      expect(await alice.care('water'), isTrue);
      expect(await alice.buy('small_pot'), isTrue);
      expect(await alice.care('sunlight'), isTrue);
      expect(await alice.care('sunlight'), isFalse);
      expect(alice.value!.stats.coins, 20);
      expect(alice.value!.inventory['water'], 0);
      alice.bindUser(null);

      final restored = clientFor('alice');
      await restored.load();
      expect(restored.value!.selectedPetId, 'koala');
      expect(restored.value!.inventory['small_pot'], 1);
      expect(restored.value!.stats.coins, 20);
      expect(restored.cooldownFor('sunlight'), greaterThan(Duration.zero));

      final bob = clientFor('bob');
      await bob.load();
      expect(bob.value!.selectedPetId, 'puppy');
      expect(bob.value!.inventory, isEmpty);
      expect(bob.value!.stats.coins, 0);
    },
  );

  test(
    'Two clients cannot spend the same balance with the same version',
    () async {
      await credit('race', 'trip-1', 0.5);
      final first = clientFor('race');
      final second = clientFor('race');
      await Future.wait([first.load(), second.load()]);
      await Future.wait([first.loadShop(), second.loadShop()]);
      final results = await Future.wait([
        first.buy('water'),
        second.buy('water'),
      ]);
      expect(results.where((result) => result).length, 1);
      await first.load();
      expect(first.value!.stats.coins, 0);
      expect(first.value!.inventory['water'], 1);
    },
  );

  test(
    'A committed purchase with a lost response is not charged again on retry',
    () async {
      await credit('retry', 'trip-1', 1);
      final data = clientFor('retry', losePurchaseResponse: true);
      await data.load();
      await data.loadShop();
      expect(await data.buy('water'), isFalse);
      expect(data.needsRetry, isTrue);
      expect(data.value!.stats.coins, 10);
      expect(await data.retry(), isTrue);
      expect(data.needsRetry, isFalse);
      expect(data.value!.stats.coins, 5);
      expect(data.value!.inventory['water'], 1);
    },
  );
}

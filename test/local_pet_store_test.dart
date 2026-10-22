import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:travelly_flutter_ios_style/core/pet_data.dart';
import 'package:travelly_flutter_ios_style/data/pet_data.dart';
import 'package:travelly_flutter_ios_style/services/local_pet_store.dart';
import 'package:travelly_flutter_ios_style/services/pet_api.dart';

import 'support/pet_fixtures.dart' show petResponse;

void main() {
  late PetDatabase database;
  late LocalPetStore store;
  late DateTime now;
  var request = 0;

  setUp(() {
    sqfliteFfiInit();
    database = PetDatabase(
      factory: createDatabaseFactoryFfi(noIsolate: true),
      path: inMemoryDatabasePath,
    );
    now = DateTime.utc(2026, 10, 13);
    store = LocalPetStore(database: database, clock: () => now);
    addTearDown(database.close);
  });

  String requestId() =>
      '00000000-0000-4000-8000-${(++request).toString().padLeft(12, '0')}';

  Future<Map<String, dynamic>> body(
    String owner,
    String operation,
    String id,
  ) async {
    final state = await store.fetch(owner);
    return {
      switch (operation) {
        'selection' => 'pet_id',
        'purchases' => 'item_id',
        'actions' => 'action_id',
        _ => 'trip_id',
      }: id,
      'version': state.version,
      'request_id': requestId(),
    };
  }

  Future<void> trip(String owner, String id, double saving) async {
    await store.save(owner, 'trips', {
      ...await body(owner, 'trips', id),
      'mode': 'Cycling',
      'saved_kg': saving,
    });
  }

  Future<void> mutate(
    String operation,
    String id, {
    String owner = 'alice',
  }) async {
    await store.save(owner, operation, await body(owner, operation, id));
  }

  test('The application uses local Pets by default', () {
    expect(PetData.instance.local, isTrue);
  });

  test(
    'Concurrent first reads share one connection and one starter record',
    () async {
      final states = await Future.wait([
        store.fetch('alice'),
        store.fetch('alice'),
      ]);
      expect(states.map((state) => state.version), everyElement(0));
      final db = await database.database;
      expect(
        await db.query('pets', where: 'owner_id = ?', whereArgs: ['alice']),
        hasLength(1),
      );
    },
  );

  test(
    'Reusing a request ID for a different purchase cannot change state',
    () async {
      await trip('alice', 'trip', 10);
      final request = await body('alice', 'purchases', 'water');
      await store.save('alice', 'purchases', request);
      await expectLater(
        store.save('alice', 'purchases', {...request, 'item_id': 'fertiliser'}),
        throwsA(
          isA<PetApiException>().having(
            (error) => error.code,
            'code',
            'request_conflict',
          ),
        ),
      );
      final state = await store.fetch('alice');
      expect(state.stats.coins, 95);
      expect(state.inventory, {'water': 1});
    },
  );

  test('Creates SQLite tables and keeps accounts separate', () async {
    final first = await store.fetch('alice');
    expect(first.stats.coins, 0);
    expect(first.stats.health, 0.8);
    await trip('alice', 'trip-1', 5);
    await mutate('selection', 'koala');
    await mutate('purchases', 'water');
    expect((await store.fetch('bob')).stats.coins, 0);
    expect((await store.fetch('bob')).selectedPetId, 'puppy');
    expect(await store.trips('bob'), isEmpty);
    expect((await store.trips('alice')).single.coins, 50);
    await store.fetchCatalogue('alice');
    expect((await database.readCatalogue())!['items']['water']['price'], 5);
  });

  test(
    'Rewards, selection, inventory and care survive closing the SQL connection',
    () async {
      final directory = await Directory.systemTemp.createTemp('travelly-pets-');
      addTearDown(() => directory.delete(recursive: true));
      final path = '${directory.path}/pets.db';
      final disk = PetDatabase(
        factory: createDatabaseFactoryFfi(noIsolate: true),
        path: path,
      );
      final original = LocalPetStore(database: disk, clock: () => now);
      final data = PetData(api: original, onChanged: (_) {}, onCleared: () {});
      data.bindUser('alice');
      await data.load();
      await data.loadShop();
      expect(await data.recordTrip('Cycling', 5), isTrue);
      expect(await data.select('koala'), isTrue);
      expect(await data.buy('water'), isTrue);
      expect(await data.care('water'), isTrue);
      expect(await data.care('sunlight'), isTrue);
      expect(await data.buy('small_pot'), isTrue);
      data.dispose();
      await disk.close();
      expect(await File(path).exists(), isTrue);
      final restoredDb = PetDatabase(
        factory: createDatabaseFactoryFfi(noIsolate: true),
        path: path,
      );
      addTearDown(restoredDb.close);
      final restored = LocalPetStore(database: restoredDb, clock: () => now);
      final state = await restored.fetch('alice');
      expect(state.selectedPetId, 'koala');
      expect(state.stats.coins, 20);
      expect(state.inventory['water'], 0);
      expect(state.inventory['small_pot'], 1);
      expect(state.stats.health, 0.9);
      expect(state.cooldowns['sunlight'], now.add(const Duration(hours: 1)));
      expect((await restored.trips('alice')).single.savedKg, 5);
    },
  );

  test('Concurrent SQL mutations cannot spend the same coins twice', () async {
    await trip('alice', 'one', 0.5);
    final first = await body('alice', 'purchases', 'water');
    final second = await body('alice', 'purchases', 'water');
    final results = await Future.wait(
      [first, second].map((request) async {
        try {
          await store.save('alice', 'purchases', request);
          return true;
        } on PetApiException catch (e) {
          expect(e.code, 'stale_version');
          return false;
        }
      }),
    );
    expect(results.where((success) => success).length, 1);
    final state = await store.fetch('alice');
    expect(state.stats.coins, 0);
    expect(state.inventory['water'], 1);
  });

  test('A delayed retry cannot consume care or award a trip twice', () async {
    final credit = {
      ...await body('alice', 'trips', 'trip-1'),
      'saved_kg': 5,
      'mode': 'Cycling',
    };
    final result = await store.save('alice', 'trips', credit);
    expect(
      (await store.save('alice', 'trips', credit)).version,
      result.version,
    );
    await mutate('purchases', 'water');
    final care = await body('alice', 'actions', 'water');
    final cared = await store.save('alice', 'actions', care);
    now = now.add(const Duration(hours: 3));
    expect((await store.save('alice', 'actions', care)).version, cared.version);
    final state = await store.fetch('alice');
    expect(state.inventory['water'], 0);
    expect(state.stats.coins, 45);
    expect(state.stats.health, 0.87);
    expect(await store.trips('alice'), hasLength(1));
    final duplicate = {
      ...await body('alice', 'trips', 'trip-1'),
      'saved_kg': 5,
      'mode': 'Cycling',
    };
    await expectLater(
      store.save('alice', 'trips', duplicate),
      throwsA(isA<PetApiException>()),
    );
    expect((await store.fetch('alice')).stats.coins, 45);
  });

  test(
    'Failed purchases and no-effect care leave balances and inventory intact',
    () async {
      await expectLater(
        mutate('purchases', 'water'),
        throwsA(isA<PetApiException>()),
      );
      await trip('alice', 'trip', 10);
      await mutate('purchases', 'kennel');
      await expectLater(
        mutate('purchases', 'kennel'),
        throwsA(isA<PetApiException>()),
      );
      await mutate('purchases', 'fertiliser');
      await mutate('purchases', 'fertiliser');
      await mutate('actions', 'fertiliser');
      final before = await store.fetch('alice');
      await expectLater(
        mutate('actions', 'fertiliser'),
        throwsA(
          isA<PetApiException>().having(
            (e) => e.code,
            'code',
            'care_not_needed',
          ),
        ),
      );
      final after = await store.fetch('alice');
      expect(after.version, before.version);
      expect(after.inventory['fertiliser'], 1);
      expect(after.stats.coins, 30);
    },
  );

  test(
    'Elapsed care is applied once and decorations protect only future time',
    () async {
      await trip('alice', 'trip', 10);
      now = now.add(const Duration(hours: 2));
      await mutate('purchases', 'small_pot');
      await mutate('purchases', 'kennel');
      final before = await store.fetch('alice');
      expect(before.stats.happiness, 0.71);
      expect(before.stats.energy, 0.57);
      now = now.add(const Duration(hours: 2));
      final after = await store.fetch('alice');
      expect(after.stats.happiness, 0.69);
      expect(after.stats.energy, 0.53);
      expect((await store.fetch('alice')).stats.energy, 0.53);
      expect(after.version, before.version);
      now = now.add(const Duration(days: 100));
      expect((await store.fetch('alice')).stats.health, 0);
    },
  );

  test('Pet switching preserves individual condition and cooldowns', () async {
    await trip('alice', 'trip', 5);
    await mutate('actions', 'sunlight');
    await mutate('selection', 'koala');
    expect((await store.fetch('alice')).cooldowns, isEmpty);
    await mutate('actions', 'sunlight');
    await mutate('selection', 'puppy');
    expect((await store.fetch('alice')).stats.energy, 0.8);
    await expectLater(
      mutate('actions', 'sunlight'),
      throwsA(isA<PetApiException>()),
    );
    now = now.add(const Duration(hours: 1));
    await mutate('actions', 'sunlight');
    expect((await store.fetch('alice')).stats.energy, 0.91);
  });

  test(
    'Rejects locked pets, malformed writes and invalid reward values',
    () async {
      await expectLater(
        mutate('selection', 'koala'),
        throwsA(isA<PetApiException>()),
      );
      await expectLater(store.fetch(''), throwsA(isA<PetApiException>()));
      for (final saving in [-1.0, double.nan, double.infinity, 1001.0]) {
        final request = {
          ...await body('alice', 'trips', requestId()),
          'saved_kg': saving,
          'mode': 'Cycling',
        };
        await expectLater(
          store.save('alice', 'trips', request),
          throwsA(isA<PetApiException>()),
        );
      }
      final invalid = {
        ...await body('alice', 'purchases', 'water'),
        'owner': 'bob',
      };
      await expectLater(
        store.save('alice', 'purchases', invalid),
        throwsA(isA<PetApiException>()),
      );
      expect((await store.fetch('alice')).stats.coins, 0);
      expect(await store.trips('alice'), isEmpty);
    },
  );

  test(
    'Upgrades the pulled version-one SQLite database without losing its pet',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'travelly-pets-upgrade-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final path = '${directory.path}/pets.db';
      final factory = createDatabaseFactoryFfi(noIsolate: true);
      final old = await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE pets (owner_id TEXT PRIMARY KEY, pet_json TEXT NOT NULL)',
            );
            await db.execute(
              'CREATE TABLE catalogues (catalogue_id TEXT PRIMARY KEY, catalogue_json TEXT NOT NULL)',
            );
          },
        ),
      );
      await old.insert('pets', {
        'owner_id': 'alice',
        'pet_json': jsonEncode(
          petResponse(pet: 'koala', coins: 33, version: 4),
        ),
      });
      await old.close();
      final upgraded = PetDatabase(factory: factory, path: path);
      addTearDown(upgraded.close);
      final local = LocalPetStore(database: upgraded, clock: () => now);
      final state = await local.fetch('alice');
      expect(state.selectedPetId, 'koala');
      expect(state.stats.coins, 33);
      expect(state.version, 4);
      expect(state.stats.health, 0.9);
      expect(await local.trips('alice'), isEmpty);
    },
  );
}

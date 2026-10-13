import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:travelly_flutter_ios_style/core/pet_data.dart';
import 'package:travelly_flutter_ios_style/models/garden_catalogue.dart';
import 'package:travelly_flutter_ios_style/screens/pet_home_page.dart';
import 'package:travelly_flutter_ios_style/screens/pet_profile_page.dart';

import 'pet_data_test.dart' show petResponse, petsWith, gardenResponse;

Future<void> openGarden(WidgetTester tester, PetData pets) async {
  await tester.binding.setSurfaceSize(const Size(430, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  pets.bindUser('alice');
  await tester.pumpWidget(
    CupertinoApp(
      localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
      home: PetHomePage(data: pets),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test(
    'Purchases wait for confirmation before changing coins or inventory',
    () async {
      final reply = Completer<http.Response>();
      final pets = petsWith((request) async {
        if (request.method == 'GET')
          return http.Response(jsonEncode(petResponse()), 200);
        expect(request.url.path, '/v1/me/pet/purchases');
        expect(
          jsonDecode(request.body).keys,
          unorderedEquals(['item_id', 'version', 'request_id']),
        );
        expect(jsonDecode(request.body)['item_id'], 'water');
        return reply.future;
      });
      pets.bindUser('alice');
      await pets.load();
      await pets.loadShop();
      final buying = pets.buy('water');
      expect(pets.value!.stats.coins, 20);
      expect(pets.value!.inventory, isEmpty);
      expect(await pets.buy('water'), isFalse);
      final state = petResponse(coins: 15, version: 1)
        ..['inventory'] = {'water': 1};
      reply.complete(http.Response(jsonEncode(state), 200));
      expect(await buying, isTrue);
      expect(pets.value!.stats.coins, 15);
      expect(pets.value!.inventory['water'], 1);
    },
  );

  test('Care consumes inventory and publishes confirmed health', () async {
    final initial = petResponse()..['inventory'] = {'water': 1};
    final pets = petsWith((request) async {
      if (request.method == 'GET')
        return http.Response(jsonEncode(initial), 200);
      expect(request.url.path, '/v1/me/pet/actions');
      expect(jsonDecode(request.body)['action_id'], 'water');
      final updated = petResponse(version: 1)..['inventory'] = {'water': 0};
      (updated['pet'] as Map<String, dynamic>)['health'] = 1.0;
      return http.Response(jsonEncode(updated), 200);
    });
    pets.bindUser('alice');
    await pets.load();
    await pets.loadShop();
    expect(await pets.care('water'), isTrue);
    expect(pets.value!.inventory['water'], 0);
    expect(pets.value!.stats.health, 1);
  });

  test(
    'Cooldown uses server time even when the device clock is wrong',
    () async {
      var clock = DateTime.utc(2050);
      var writes = 0;
      final state = petResponse()
        ..['server_time'] = '2026-10-13T00:00:00Z'
        ..['cooldowns'] = {'sunlight': '2026-10-13T01:00:00Z'};
      final pets = petsWith((request) async {
        if (request.method != 'GET') writes++;
        return http.Response(jsonEncode(state), 200);
      }, clock: () => clock);
      pets.bindUser('alice');
      await pets.load();
      await pets.loadShop();
      expect(pets.cooldownFor('sunlight'), const Duration(hours: 1));
      expect(await pets.care('sunlight'), isFalse);
      expect(writes, 0);
      clock = clock.add(const Duration(hours: 1));
      expect(pets.cooldownFor('sunlight'), Duration.zero);
      expect(await pets.care('sunlight'), isTrue);
      expect(writes, 1);
    },
  );

  test('A failed purchase keeps the confirmed balance and inventory', () async {
    final pets = petsWith(
      (request) async => request.method == 'GET'
          ? http.Response(jsonEncode(petResponse()), 200)
          : http.Response(
              '{"code":"insufficient_coins","message":"Not enough coins"}',
              409,
            ),
    );
    pets.bindUser('alice');
    await pets.load();
    await pets.loadShop();
    expect(await pets.buy('kennel'), isFalse);
    expect(pets.value!.stats.coins, 20);
    expect(pets.value!.inventory, isEmpty);
    expect(pets.error, 'Not enough coins');
    expect(pets.needsRetry, isFalse);
  });

  test(
    'Old account shop responses cannot restore its prices or pending actions',
    () async {
      final oldShop = Completer<http.Response>();
      final pets = petsWith(
        (_) async => http.Response(jsonEncode(petResponse()), 200),
        catalogue: (request) async {
          if (request.headers['Authorization'] == 'Bearer token-alice')
            return oldShop.future;
          return http.Response(jsonEncode(gardenResponse(waterPrice: 7)), 200);
        },
      );
      pets.bindUser('alice');
      await pets.load();
      final oldLoad = pets.loadShop();
      pets.bindUser('bob');
      await pets.load();
      oldShop.complete(
        http.Response(jsonEncode(gardenResponse(waterPrice: 99)), 200),
      );
      await oldLoad;
      expect(pets.owner, 'bob');
      expect(pets.shop!.items['water']!.price, 7);
    },
  );

  test('Invalid catalogue prices are rejected', () {
    final json = gardenResponse(waterPrice: -1);
    expect(() => GardenCatalogue.fromJson(json), throwsFormatException);
  });

  testWidgets(
    'Garden uses server prices and confirms before sending a purchase',
    (tester) async {
      var writes = 0;
      var state = petResponse();
      final pets = petsWith(
        (request) async {
          if (request.method == 'GET')
            return http.Response(jsonEncode(state), 200);
          writes++;
          state = petResponse(coins: 7, version: 1)
            ..['inventory'] = {'water': 1};
          return http.Response(jsonEncode(state), 200);
        },
        catalogue: (_) async =>
            http.Response(jsonEncode(gardenResponse(waterPrice: 13)), 200),
      );
      await openGarden(tester, pets);
      expect(find.text('13 coins'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pet-action-water')));
      await tester.pumpAndSettle();
      expect(writes, 0);
      expect(find.text('Buy Water (13 coins)'), findsOneWidget);
      await tester.tap(find.text('Buy Water (13 coins)'));
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(find.text('1 owned'), findsOneWidget);
      expect(pets.value!.stats.coins, 7);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Owned decorations appear and the shop opens from More', (
    tester,
  ) async {
    final state = petResponse(coins: 100)
      ..['inventory'] = {'small_pot': 1, 'kennel': 1};
    final pets = petsWith((_) async => http.Response(jsonEncode(state), 200));
    await openGarden(tester, pets);
    expect(find.byKey(const ValueKey('garden-small-pot')), findsOneWidget);
    expect(find.byKey(const ValueKey('garden-kennel')), findsOneWidget);
    expect(find.text('Owned'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('pet-action-more')));
    await tester.pumpAndSettle();
    expect(find.text('Garden shop'), findsOneWidget);
    expect(find.text('Fertiliser · 10 coins'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Using water updates the saved profile condition', (
    tester,
  ) async {
    var state = petResponse()..['inventory'] = {'water': 1};
    final pets = petsWith((request) async {
      if (request.method == 'POST') {
        state = petResponse(version: 1)..['inventory'] = {'water': 0};
        (state['pet'] as Map<String, dynamic>)['health'] = 1;
      }
      return http.Response(jsonEncode(state), 200);
    });
    await openGarden(tester, pets);
    await tester.tap(find.byKey(const ValueKey('pet-action-water')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use Water'));
    await tester.pumpAndSettle();
    expect(pets.value!.inventory['water'], 0);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(PetProfilePage), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Shop failures provide a retry instead of fabricated prices', (
    tester,
  ) async {
    var attempts = 0;
    final pets = petsWith(
      (_) async => http.Response(jsonEncode(petResponse()), 200),
      catalogue: (_) async {
        attempts++;
        return attempts == 1
            ? http.Response('{"message":"Shop unavailable"}', 500)
            : http.Response(jsonEncode(gardenResponse()), 200);
      },
    );
    await openGarden(tester, pets);
    expect(find.text('Shop unavailable'), findsOneWidget);
    expect(find.text('Reload shop'), findsOneWidget);
    await tester.tap(find.text('Reload shop'));
    await tester.pumpAndSettle();
    expect(find.text('Shop unavailable'), findsNothing);
    expect(find.text('5 coins'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

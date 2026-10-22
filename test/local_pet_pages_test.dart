import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:travelly_flutter_ios_style/core/pet_data.dart';
import 'package:travelly_flutter_ios_style/data/pet_data.dart';
import 'package:travelly_flutter_ios_style/screens/activities_page.dart';
import 'package:travelly_flutter_ios_style/screens/pet_home_page.dart';
import 'package:travelly_flutter_ios_style/screens/pet_selection_page.dart';
import 'package:travelly_flutter_ios_style/services/local_pet_store.dart';

void main() {
  late PetDatabase database;
  late PetData pets;

  setUp(() {
    sqfliteFfiInit();
    database = PetDatabase(
      factory: createDatabaseFactoryFfi(noIsolate: true),
      path: inMemoryDatabasePath,
    );
    pets = PetData(
      api: LocalPetStore(
        database: database,
        clock: () => DateTime.utc(2026, 10, 13),
      ),
      onChanged: (_) {},
      onCleared: () {},
      clock: () => DateTime.utc(2026, 10, 13),
    );
    pets.bindUser('alice');
    addTearDown(pets.dispose);
    addTearDown(database.close);
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
    }
    await tester.pumpAndSettle();
  }

  Future<void> open(
    WidgetTester tester,
    Widget page, {
    Size size = const Size(430, 1100),
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() async {
      await pets.load();
      await pets.loadShop();
    });
    await tester.pumpWidget(
      CupertinoApp(
        localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: page,
      ),
    );
    await settle(tester);
  }

  testWidgets(
    'A local trip earns saved rewards and funds care from the garden',
    (tester) async {
      await open(tester, PetHomePage(data: pets));
      await tester.ensureVisible(find.text('Activities'));
      await settle(tester);
      await tester.tap(find.text('Activities'));
      await settle(tester);
      await tester.tap(find.text('Record a local trip'));
      await settle(tester);
      expect(pets.value!.stats.coins, 0);
      await tester.tap(find.text('Cycling · 1.0 kg CO₂ · 10 coins'));
      await settle(tester);
      expect(find.text('10 coins'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
      expect(pets.value!.co2SavedKg, 1);
      expect(await tester.runAsync(pets.tripHistory), hasLength(1));
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await settle(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('pet-action-water')),
      );
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('pet-action-water')));
      await settle(tester);
      await tester.tap(find.text('Buy Water (5 coins)'));
      await settle(tester);
      expect(pets.value!.stats.coins, 5);
      expect(pets.value!.inventory['water'], 1);
      await tester.tap(find.byKey(const ValueKey('pet-action-water')));
      await settle(tester);
      await tester.tap(find.text('Use Water'));
      await settle(tester);
      expect(pets.value!.stats.health, 0.9);
      expect(pets.value!.inventory['water'], 0);
      expect(find.text('Health: 90%'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('The garden lets the user return to selection', (tester) async {
    await open(tester, PetHomePage(data: pets));
    await tester.tap(find.text('Change pet'));
    await settle(tester);
    expect(find.byType(PetSelectionPage), findsOneWidget);
    expect(find.text('Keep Scout'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Local activity history clears when the signed-in account changes',
    (tester) async {
      await tester.runAsync(() async {
        await pets.load();
        await pets.recordTrip('Walking', 0.5);
      });
      await open(tester, ActivitiesPage(data: pets));
      expect(find.text('Walking'), findsOneWidget);
      pets.bindUser('bob');
      await settle(tester);
      await tester.runAsync(pets.load);
      await settle(tester);
      expect(find.text('Walking'), findsNothing);
      expect(find.text('No local trips recorded yet.'), findsOneWidget);
      expect(find.text('0 coins'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Local activities fit a small screen with larger text', (
    tester,
  ) async {
    await open(
      tester,
      ActivitiesPage(data: pets),
      size: const Size(320, 568),
      scale: 1.5,
    );
    await tester.tap(find.text('Record a local trip'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(pets.value!.stats.coins, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

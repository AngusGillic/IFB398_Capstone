import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:travelly_flutter_ios_style/screens/pet_selection_page.dart';
import 'package:travelly_flutter_ios_style/screens/pet_profile_page.dart';

import 'pet_data_test.dart' show petResponse, petsWith;

void main() {
  testWidgets(
    'Restores the saved pet and keeps the page open if selection fails',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pets = petsWith((request) async {
        if (request.method == 'GET')
          return http.Response(jsonEncode(petResponse(pet: 'koala')), 200);
        return http.Response(
          '{"code":"pet_locked","message":"This pet is still locked"}',
          409,
        );
      });
      pets.bindUser('alice');
      await tester.pumpWidget(
        CupertinoApp(
          localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
          home: PetSelectionPage(data: pets),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Keep Mira'), findsOneWidget);
      await tester.tap(find.text('Scout').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Raise Scout'));
      await tester.pumpAndSettle();
      expect(find.byType(PetSelectionPage), findsOneWidget);
      expect(find.text('This pet is still locked'), findsOneWidget);
      expect(pets.value!.selectedPetId, 'koala');
    },
  );

  testWidgets('Profile shows a loading state then saved care stats', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    final pets = petsWith((_) => response.future);
    pets.bindUser('alice');
    await tester.pumpWidget(
      CupertinoApp(
        localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
        home: PetProfilePage(data: pets),
      ),
    );
    expect(find.text('Loading your pet…'), findsOneWidget);
    response.complete(
      http.Response(jsonEncode(petResponse(pet: 'koala')), 200),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mira'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    pets.bindUser('bob');
    await tester.pump();
    expect(find.text('Mira'), findsNothing);
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travelly_flutter_ios_style/core/pet_data.dart';
import 'package:travelly_flutter_ios_style/services/pet_api.dart';

Map<String, dynamic> petResponse({
  String pet = 'puppy',
  int version = 0,
  int coins = 20,
}) => {
  'selected_pet_id': pet,
  'adopted_at': '2026-10-13T00:00:00Z',
  'pet': {
    'coins': coins,
    'happiness': 0.8,
    'energy': 0.6,
    'health': 0.9,
    'days_together': 2,
  },
  'inventory': <String, int>{},
  'co2_saved_kg': 10,
  'version': version,
};

PetData petsWith(
  Future<http.Response> Function(http.Request) handler, {
  void Function(String)? ownerUsed,
  bool publish = false,
  DateTime Function()? clock,
  Future<http.Response> Function(http.Request)? catalogue,
}) {
  final client = MockClient((request) {
    if (request.url.path.endsWith('/catalogue')) {
      return catalogue != null
          ? catalogue(request)
          : Future.value(http.Response(jsonEncode(gardenResponse()), 200));
    }
    return handler(request);
  });
  addTearDown(client.close);
  final data = PetData(
    api: PetApi(
      client: client,
      baseUrl: 'https://pets.example',
      accessToken: (owner) async {
        ownerUsed?.call(owner);
        return 'token-$owner';
      },
    ),
    onChanged: publish ? null : (_) {},
    onCleared: publish ? null : () {},
    clock: clock,
  );
  addTearDown(data.dispose);
  return data;
}

Map<String, dynamic> gardenResponse({int waterPrice = 5}) => {
  'items': {
    'small_pot': {'price': 25, 'durable': true},
    'water': {'price': waterPrice, 'durable': false},
    'fertiliser': {'price': 10, 'durable': false},
    'kennel': {'price': 50, 'durable': true},
  },
  'actions': {'water': {}, 'fertiliser': {}, 'sunlight': {}},
};

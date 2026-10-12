import 'package:flutter_test/flutter_test.dart';
import 'package:travelly_flutter_ios_style/models/pet_state.dart';

Map<String, dynamic> snapshot() => {
  'selected_pet_id': 'puppy',
  'adopted_at': '2026-10-13T00:00:00Z',
  'pet': {
    'coins': 30,
    'happiness': 0.85,
    'energy': 1,
    'health': 0.93,
    'days_together': 2,
  },
  'inventory': {'water': 2},
  'co2_saved_kg': 5.5,
  'version': 3,
};

void main() {
  test('Loads selection, stats and inventory from a server snapshot', () {
    final state = PetState.fromJson(snapshot());

    expect(state.selectedPetId, 'puppy');
    expect(state.adoptedAt, DateTime.utc(2026, 10, 13));
    expect(state.stats.coins, 30);
    expect(state.stats.happiness, 0.85);
    expect(state.stats.energy, 1.0);
    expect(state.stats.health, 0.93);
    expect(state.stats.daysTogether, 2);
    expect(state.inventory['water'], 2);
    expect(state.co2SavedKg, 5.5);
    expect(state.version, 3);
    expect(() => state.inventory['water'] = 4, throwsUnsupportedError);
  });

  test('Rejects invalid balances, quantities and care stats', () {
    for (final entry in {
      'coins': -1,
      'happiness': 1.5,
      'energy': double.nan,
      'health': double.infinity,
      'days_together': 2.5,
    }.entries) {
      final json = snapshot();
      (json['pet'] as Map<String, dynamic>)[entry.key] = entry.value;
      expect(() => PetState.fromJson(json), throwsFormatException);
    }

    final json = snapshot();
    json['inventory'] = {'water': -1};
    expect(() => PetState.fromJson(json), throwsFormatException);
  });

  test('Rejects an empty selection and a date without a timezone', () {
    final json = snapshot();
    json['selected_pet_id'] = '';
    expect(() => PetState.fromJson(json), throwsFormatException);

    json['selected_pet_id'] = 'puppy';
    json['adopted_at'] = '2026-10-13T00:00:00';
    expect(() => PetState.fromJson(json), throwsFormatException);
  });
}

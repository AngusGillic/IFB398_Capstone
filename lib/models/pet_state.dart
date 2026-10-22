import '../data/user_data.dart';

class PetState {
  const PetState({
    required this.selectedPetId,
    required this.adoptedAt,
    required this.stats,
    required this.inventory,
    required this.co2SavedKg,
    required this.version,
    this.serverTime,
    this.cooldowns = const {},
  });

  final String selectedPetId;
  final DateTime adoptedAt;
  final PetStats stats;
  final Map<String, int> inventory;
  final double co2SavedKg;
  final int version;
  final DateTime? serverTime;
  final Map<String, DateTime> cooldowns;

  factory PetState.fromJson(Map<String, dynamic> json) {
    final pet = json['pet'] as Map<String, dynamic>;
    final inventory = json['inventory'] as Map<String, dynamic>;
    final selectedPetId = json['selected_pet_id'] as String;
    final adoptedAt = DateTime.parse(json['adopted_at'] as String);

    if (selectedPetId.isEmpty || !adoptedAt.isUtc) {
      throw const FormatException('Invalid pet selection or adoption date');
    }

    return PetState(
      selectedPetId: selectedPetId,
      adoptedAt: adoptedAt,
      stats: PetStats(
        coins: _wholeNumber(pet['coins']),
        happiness: _ratio(pet['happiness']),
        energy: _ratio(pet['energy']),
        health: _ratio(pet['health']),
        daysTogether: _wholeNumber(pet['days_together']),
      ),
      inventory: Map.unmodifiable(
        inventory.map((id, quantity) => MapEntry(id, _wholeNumber(quantity))),
      ),
      co2SavedKg: _number(json['co2_saved_kg']),
      version: _wholeNumber(json['version']),
      serverTime: json['server_time'] == null
          ? null
          : _utcDate(json['server_time']),
      cooldowns: Map.unmodifiable(
        ((json['cooldowns'] as Map<String, dynamic>?) ?? {}).map(
          (id, until) => MapEntry(id, _utcDate(until)),
        ),
      ),
    );
  }

  static DateTime _utcDate(Object? value) {
    final date = DateTime.parse(value as String);
    if (!date.isUtc) throw const FormatException('Expected a UTC date');
    return date;
  }

  static double _number(Object? value) {
    if (value is! num || !value.isFinite || value < 0) {
      throw const FormatException('Expected a non-negative number');
    }
    return value.toDouble();
  }

  static int _wholeNumber(Object? value) {
    final number = _number(value);
    if (number != number.truncateToDouble()) {
      throw const FormatException('Expected a whole number');
    }
    return number.toInt();
  }

  static double _ratio(Object? value) {
    final number = _number(value);
    if (number > 1) {
      throw const FormatException('Pet stats must be between 0 and 1');
    }
    return number;
  }
}

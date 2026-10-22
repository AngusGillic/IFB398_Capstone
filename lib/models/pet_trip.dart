class PetTrip {
  const PetTrip({
    required this.id,
    required this.mode,
    required this.savedKg,
    required this.coins,
    required this.completedAt,
  });

  final String id;
  final String mode;
  final double savedKg;
  final int coins;
  final DateTime completedAt;

  factory PetTrip.fromRow(Map<String, Object?> row) => PetTrip(
    id: row['trip_id'] as String,
    mode: row['mode'] as String,
    savedKg: (row['saved_kg'] as num).toDouble(),
    coins: row['coins'] as int,
    completedAt: DateTime.parse(row['completed_at'] as String),
  );
}

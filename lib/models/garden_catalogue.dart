class GardenItem {
  const GardenItem({
    required this.id,
    required this.price,
    required this.durable,
  });

  final String id;
  final int price;
  final bool durable;

  String get name => switch (id) {
    'small_pot' => 'Small pot',
    'water' => 'Water',
    'fertiliser' => 'Fertiliser',
    'kennel' => 'Kennel',
    _ => id.replaceAll('_', ' '),
  };
}

class GardenCatalogue {
  const GardenCatalogue({required this.items, required this.actions});

  final Map<String, GardenItem> items;
  final Set<String> actions;

  factory GardenCatalogue.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as Map<String, dynamic>;
    final actions = json['actions'] as Map<String, dynamic>;
    return GardenCatalogue(
      items: Map.unmodifiable(
        items.map((id, raw) {
          final item = raw as Map<String, dynamic>;
          final price = item['price'];
          if (price is! int || price < 0 || item['durable'] is! bool) {
            throw const FormatException('Invalid garden item');
          }
          return MapEntry(
            id,
            GardenItem(id: id, price: price, durable: item['durable'] as bool),
          );
        }),
      ),
      actions: Set.unmodifiable(actions.keys),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map(
        (id, item) =>
            MapEntry(id, {'price': item.price, 'durable': item.durable}),
      ),
      'actions': {for (final action in actions) action: true},
    };
  }
}

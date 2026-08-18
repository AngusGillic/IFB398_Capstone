import 'package:flutter/cupertino.dart';

enum PetRarity { starter, common, rare, legendary }

extension PetRarityMeta on PetRarity {
  String get label => switch (this) {
        PetRarity.starter => 'Starter',
        PetRarity.common => 'Common',
        PetRarity.rare => 'Rare',
        PetRarity.legendary => 'Legendary',
      };

  Color get color => switch (this) {
        PetRarity.starter => const Color(0xFF8E8E93),
        PetRarity.common => const Color(0xFF34C759),
        PetRarity.rare => const Color(0xFF007AFF),
        PetRarity.legendary => const Color(0xFFAF52DE),
      };
}

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.habitat,
    required this.blurb,
    required this.rarity,
    required this.unlockCo2Kg,
    required this.accent,
  });

  final String id;
  final String name;
  final String species;
  final String habitat;
  final String blurb;
  final PetRarity rarity;

  /// Lifetime CO2 saving required before this pet becomes available.
  final double unlockCo2Kg;

  final Color accent;

  bool isUnlockedAt(double savedKg) => savedKg >= unlockCo2Kg;

  double progressAt(double savedKg) =>
      unlockCo2Kg <= 0 ? 1 : (savedKg / unlockCo2Kg).clamp(0.0, 1.0);
}

class PetCatalogue {
  const PetCatalogue._();

  static const List<Pet> all = [
    Pet(
      id: 'puppy',
      name: 'Scout',
      species: 'Dingo pup',
      habitat: 'Backyard',
      blurb: 'First to the door every single morning.',
      rarity: PetRarity.starter,
      unlockCo2Kg: 0,
      accent: Color(0xFFFF9500),
    ),
    Pet(
      id: 'koala',
      name: 'Mira',
      species: 'Koala',
      habitat: 'Eucalypt canopy',
      blurb: 'Sleeps twenty hours a day. Not remotely sorry about it.',
      rarity: PetRarity.common,
      unlockCo2Kg: 5,
      accent: Color(0xFF8E8E93),
    ),
    Pet(
      id: 'frill',
      name: 'Frillie',
      species: 'Frill-necked lizard',
      habitat: 'Dry woodland',
      blurb: 'Runs on two legs when startled, which is often.',
      rarity: PetRarity.common,
      unlockCo2Kg: 10,
      accent: Color(0xFF32ADE6),
    ),
    Pet(
      id: 'kanga',
      name: 'Kanga',
      species: 'Red kangaroo',
      habitat: 'Open grassland',
      blurb: 'Nine metres in a single bound.',
      rarity: PetRarity.common,
      unlockCo2Kg: 18,
      accent: Color(0xFFD85A30),
    ),
    Pet(
      id: 'wombat',
      name: 'Barrel',
      species: 'Wombat',
      habitat: 'Burrow',
      blurb: 'Slow. Determined. Unbothered by hills.',
      rarity: PetRarity.common,
      unlockCo2Kg: 28,
      accent: Color(0xFF9E7B5A),
    ),
    Pet(
      id: 'quokka',
      name: 'Sunny',
      species: 'Quokka',
      habitat: 'Coastal scrub',
      blurb: 'Looks pleased in every photograph ever taken of one.',
      rarity: PetRarity.rare,
      unlockCo2Kg: 45,
      accent: Color(0xFFFFCC00),
    ),
    Pet(
      id: 'echidna',
      name: 'Prickle',
      species: 'Short-beaked echidna',
      habitat: 'Leaf litter',
      blurb: 'Keeps to itself, mostly after dark.',
      rarity: PetRarity.rare,
      unlockCo2Kg: 65,
      accent: Color(0xFF6D6A63),
    ),
    Pet(
      id: 'platypus',
      name: 'Ripple',
      species: 'Platypus',
      habitat: 'River bank',
      blurb: 'Lays eggs, has a bill, and is venomous. Nature was experimenting.',
      rarity: PetRarity.rare,
      unlockCo2Kg: 90,
      accent: Color(0xFF1D9E75),
    ),
    Pet(
      id: 'cockatoo',
      name: 'Screech',
      species: 'Sulphur-crested cockatoo',
      habitat: 'Treetops',
      blurb: 'Audible from three streets away. Smarter than it lets on.',
      rarity: PetRarity.legendary,
      unlockCo2Kg: 130,
      accent: Color(0xFFFFD60A),
    ),
    Pet(
      id: 'cassowary',
      name: 'Emerald',
      species: 'Southern cassowary',
      habitat: 'Rainforest floor',
      blurb: 'Two metres tall and faster than you. Almost never seen.',
      rarity: PetRarity.legendary,
      unlockCo2Kg: 200,
      accent: Color(0xFF0F6E56),
    ),
  ];

  static Pet byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);

  static int unlockedCount(double savedKg) =>
      all.where((p) => p.isUnlockedAt(savedKg)).length;

  /// The cheapest pet the user has not yet earned.
  static Pet? nextLocked(double savedKg) {
    for (final pet in all) {
      if (!pet.isUnlockedAt(savedKg)) return pet;
    }
    return null;
  }
}

/// Which pet the user is currently raising.
class PetController extends ValueNotifier<String> {
  PetController._() : super(PetCatalogue.all.first.id);

  static final PetController instance = PetController._();

  Pet get selected => PetCatalogue.byId(value);

  void select(String id) => value = id;
}

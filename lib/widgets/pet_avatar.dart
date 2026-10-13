import 'package:flutter/cupertino.dart';

import '../models/pet.dart';
import '../ui/glass.dart';

class PetAvatar extends StatelessWidget {
  const PetAvatar({super.key, required this.pet, this.size = 92});

  final Pet pet;
  final double size;

  String get _symbol => switch (pet.id) {
    'puppy' => '🐕',
    'koala' => '🐨',
    'frill' => '🦎',
    'kanga' => '🦘',
    'echidna' => '🦔',
    'cockatoo' => '🦜',
    'cassowary' => '🐦',
    _ => '🐾',
  };

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${pet.name}, ${pet.species}',
    image: true,
    child: ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: pet.accent.withValues(alpha: 0.16),
          shape: LGShape.border(LGRadius.lg),
        ),
        child: Text(_symbol, style: TextStyle(fontSize: size * 0.6)),
      ),
    ),
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../data/user_data.dart';
import '../models/pet.dart';
import '../ui/entrance.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';
import 'pet_home_page.dart';

class PetSelectionPage extends StatefulWidget {
  const PetSelectionPage({super.key});

  @override
  State<PetSelectionPage> createState() => _PetSelectionPageState();
}

class _PetSelectionPageState extends State<PetSelectionPage> {
  double get _savedKg => AppData.current.lifetime.co2SavedKg;

  late String _focused = PetController.instance.value;

  Pet get _pet => PetCatalogue.byId(_focused);
  bool get _unlocked => _pet.isUnlockedAt(_savedKg);

  void _choose(Pet pet) {
    HapticFeedback.selectionClick();
    setState(() => _focused = pet.id);
  }

  void _confirm() {
    PetController.instance.select(_focused);
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const PetHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = PetCatalogue.all.where((p) => p.isUnlockedAt(_savedKg)).toList();
    final locked = PetCatalogue.all.where((p) => !p.isUnlockedAt(_savedKg)).toList();
    final next = locked.isEmpty ? null : locked.first;
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    var row = 0;

    return AppShell(
      showBottomNav: true,
      selectedIndex: 4,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Entrance(
            index: 0,
            offset: 0,
            child: _Hero(pet: _pet, unlocked: _unlocked, savedKg: _savedKg),
          ),
          Expanded(
            child: ListView(
              physics:
                  const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: EdgeInsets.fromLTRB(
                LGGap.edge,
                LGGap.lg,
                LGGap.edge,
                MediaQuery.paddingOf(context).bottom + AppShell.navHeight + LGGap.section,
              ),
              children: [
                Entrance(
                  index: ++row,
                  child: GlassButton(
                    label: _unlocked
                        ? (_pet.id == PetController.instance.value
                            ? 'Keep ${_pet.name}'
                            : 'Raise ${_pet.name}')
                        : '${_pet.name} is still out there',
                    icon: _unlocked
                        ? CupertinoIcons.check_mark
                        : CupertinoIcons.lock_fill,
                    onPressed: _unlocked ? _confirm : null,
                  ),
                ),
                const SizedBox(height: LGGap.section),

                if (next != null) ...[
                  Entrance(index: ++row, child: _NextUp(pet: next, savedKg: _savedKg)),
                  const SizedBox(height: LGGap.section),
                ],

                Entrance(
                  index: ++row,
                  child: _SectionHeader(
                    title: 'With you now',
                    trailing: '${unlocked.length}',
                  ),
                ),
                Entrance(
                  index: ++row,
                  child: _PetGrid(
                    pets: unlocked,
                    focused: _focused,
                    savedKg: _savedKg,
                    onTap: _choose,
                  ),
                ),

                if (locked.isNotEmpty) ...[
                  const SizedBox(height: LGGap.section),
                  Entrance(
                    index: ++row,
                    child: _SectionHeader(
                      title: 'Still out there',
                      trailing: '${locked.length}',
                    ),
                  ),
                  const SizedBox(height: LGGap.xs),
                  Entrance(
                    index: ++row,
                    child: Text(
                      'Each one turns up once you have saved enough carbon.',
                      style: LGText.footnote(context).copyWith(color: secondary),
                    ),
                  ),
                  const SizedBox(height: LGGap.lg),
                  Entrance(
                    index: ++row,
                    child: _PetGrid(
                      pets: locked,
                      focused: _focused,
                      savedKg: _savedKg,
                      onTap: _choose,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LGGap.lg),
      child: Row(
        children: [
          Text(title, style: LGText.title3(context)),
          const SizedBox(width: LGGap.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: LGGap.md, vertical: 1),
            decoration: ShapeDecoration(
              color: LGColor.resolve(LGColor.fill, context),
              shape: LGShape.border(LGRadius.pill),
            ),
            child: Text(
              trailing,
              style: LGText.caption2(context).copyWith(
                color: LGColor.resolve(LGColor.secondaryLabel, context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The nearest unlock.
class _NextUp extends StatelessWidget {
  const _NextUp({required this.pet, required this.savedKg});

  final Pet pet;
  final double savedKg;

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);
    final remaining = pet.unlockCo2Kg - savedKg;

    return GlassSurface(
      radius: LGRadius.md,
      dense: true,
      padding: const EdgeInsets.all(LGGap.edge),
      shadows: LGShadow.low(context),
      child: Row(
        children: [
          _PetArt(size: 46, accent: pet.accent, dimmed: true),
          const SizedBox(width: LGGap.edge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next: ${pet.name} the ${pet.species.toLowerCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LGText.subhead(context).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: LGGap.sm),
                GlassProgress(value: pet.progressAt(savedKg), height: 5),
                const SizedBox(height: LGGap.sm),
                Text(
                  '${remaining.toStringAsFixed(0)} kg of CO₂ to go',
                  style: LGText.caption1(context).copyWith(color: secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetGrid extends StatelessWidget {
  const _PetGrid({
    required this.pets,
    required this.focused,
    required this.savedKg,
    required this.onTap,
  });

  final List<Pet> pets;
  final String focused;
  final double savedKg;
  final ValueChanged<Pet> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: LGGap.lg,
        mainAxisSpacing: LGGap.lg,
        childAspectRatio: 0.74,
      ),
      itemBuilder: (context, i) {
        final pet = pets[i];
        return _PetTile(
          pet: pet,
          selected: pet.id == focused,
          unlocked: pet.isUnlockedAt(savedKg),
          onTap: () => onTap(pet),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.pet, required this.unlocked, required this.savedKg});

  final Pet pet;
  final bool unlocked;
  final double savedKg;

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);
    final top = MediaQuery.paddingOf(context).top;

    return AnimatedContainer(
      duration: LGMotion.slow,
      curve: LGMotion.standard,
      padding: EdgeInsets.fromLTRB(
          LGGap.edge, top + LGGap.section, LGGap.edge, LGGap.section),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            pet.accent.withValues(alpha: 0.22),
            pet.accent.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          _PetArt(size: 124, accent: pet.accent, dimmed: !unlocked, locked: !unlocked),
          const SizedBox(height: LGGap.edge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  pet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LGText.title1(context),
                ),
              ),
              const SizedBox(width: LGGap.md),
              GlassPill(label: pet.rarity.label, color: pet.rarity.color),
            ],
          ),
          const SizedBox(height: LGGap.xxs),
          Text(
            '${pet.species} · ${pet.habitat.toLowerCase()}',
            style: LGText.footnote(context).copyWith(color: secondary),
          ),
          const SizedBox(height: LGGap.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LGGap.section),
            child: Text(
              pet.blurb,
              textAlign: TextAlign.center,
              style: LGText.subhead(context).copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetTile extends StatelessWidget {
  const _PetTile({
    required this.pet,
    required this.selected,
    required this.unlocked,
    required this.onTap,
  });

  final Pet pet;
  final bool selected;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    return GlassTappable(
      haptic: false,
      onTap: onTap,
      child: AnimatedContainer(
        duration: LGMotion.medium,
        curve: LGMotion.standard,
        foregroundDecoration: selected
            ? ShapeDecoration(
                shape: LGShape.border(
                  LGRadius.md,
                  side: BorderSide(color: pet.accent, width: 2),
                ),
              )
            : null,
        child: GlassSurface(
          radius: LGRadius.md,
          blur: LGGlass.blurLight,
          dense: true,
          tint: selected ? pet.accent.withValues(alpha: 0.10) : null,
          padding: const EdgeInsets.all(LGGap.lg),
          shadows: LGShadow.low(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PetArt(
                size: 50,
                accent: pet.accent,
                dimmed: !unlocked,
                locked: !unlocked,
              ),
              const SizedBox(height: LGGap.lg),
              Text(
                pet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LGText.caption1(context).copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: unlocked
                      ? LGColor.resolve(LGColor.label, context)
                      : secondary,
                ),
              ),
              const SizedBox(height: LGGap.xxs),
              Text(
                unlocked ? pet.rarity.label : '${pet.unlockCo2Kg.toStringAsFixed(0)} kg',
                maxLines: 1,
                style: LGText.caption2(context).copyWith(
                  color: unlocked ? pet.rarity.color : secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Artwork slot. Replace the inner box with Image.asset.
class _PetArt extends StatelessWidget {
  const _PetArt({
    required this.size,
    required this.accent,
    this.dimmed = false,
    this.locked = false,
  });

  final double size;
  final Color accent;
  final bool dimmed;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final radius = size > 80 ? LGRadius.lg : LGRadius.sm;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: ShapeDecoration(
              color: accent.withValues(alpha: dimmed ? 0.06 : 0.14),
              shape: LGShape.border(radius),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size * 0.11),
            child: Opacity(
              opacity: dimmed ? 0.35 : 1,
              child: Container(
                decoration: ShapeDecoration(
                  color: dark ? const Color(0xFF2C2C2E) : const Color(0xFFFFFFFF),
                  shape: LGShape.border(
                    radius - 3,
                    side: BorderSide(
                      color: LGColor.resolve(LGColor.separator, context)
                          .withValues(alpha: 0.35),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (locked)
            Icon(
              CupertinoIcons.lock_fill,
              size: size * 0.24,
              color: LGColor.resolve(LGColor.secondaryLabel, context),
            ),
        ],
      ),
    );
  }
}

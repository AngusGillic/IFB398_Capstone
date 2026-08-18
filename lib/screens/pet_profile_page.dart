import 'package:flutter/cupertino.dart';

import '../data/user_data.dart';
import '../models/pet.dart';
import '../ui/entrance.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/charts.dart';

class PetProfilePage extends StatelessWidget {
  const PetProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: PetController.instance,
      builder: (context, _, __) => _build(context, PetController.instance.selected),
    );
  }

  Widget _build(BuildContext context, Pet pet) {
    final data = AppData.current;
    final savedKg = data.lifetime.co2SavedKg;
    final stats = data.pet;

    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);
    final eco = LGColor.resolve(LGColor.eco, context);
    final effort = LGColor.resolve(LGColor.effort, context);
    final accent = LGColor.resolve(LGColor.accent, context);

    final level = (savedKg / 12).floor() + 1;
    final levelProgress = (savedKg % 12) / 12;

    return AppShell(
      showBottomNav: true,
      selectedIndex: 4,
      padding: EdgeInsets.zero,
      child: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(
          LGGap.edge,
          MediaQuery.paddingOf(context).top + LGGap.md,
          LGGap.edge,
          MediaQuery.paddingOf(context).bottom + AppShell.navHeight + LGGap.section,
        ),
        children: [
          Entrance(index: 0, child: const BackTitle(title: 'Profile')),

          Entrance(index: 1, child: Center(
            child: Column(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: ShapeDecoration(
                    color: CupertinoTheme.brightnessOf(context) == Brightness.dark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFFFFFFF),
                    shape: LGShape.border(
                      LGRadius.lg,
                      side: BorderSide(
                        color: LGColor.resolve(LGColor.separator, context)
                            .withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: LGGap.edge),
                Text(pet.name, style: LGText.title1(context)),
                const SizedBox(height: LGGap.xxs),
                Text(
                  '${pet.species} · ${pet.habitat}',
                  style: LGText.subhead(context).copyWith(color: secondary),
                ),
                const SizedBox(height: LGGap.lg),
                GlassPill(label: pet.rarity.label, color: pet.rarity.color),
              ],
            ),
          )),
          const SizedBox(height: LGGap.section),

          Entrance(index: 2, child: GreyPanel(
            padding: const EdgeInsets.all(LGGap.edge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Level $level', style: LGText.headline(context)),
                    const Spacer(),
                    Text(
                      '${(levelProgress * 100).round()}% to level ${level + 1}',
                      style: LGText.caption1(context).copyWith(color: secondary),
                    ),
                  ],
                ),
                const SizedBox(height: LGGap.lg),
                GlassProgress(value: levelProgress),
              ],
            ),
          )),
          const SizedBox(height: LGGap.lg),

          Entrance(index: 3, child: GreyPanel(
            padding: const EdgeInsets.all(LGGap.edge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About ${pet.name}', style: LGText.headline(context)),
                const SizedBox(height: LGGap.md),
                Text(
                  pet.blurb,
                  style: LGText.footnote(context).copyWith(color: secondary, height: 1.45),
                ),
              ],
            ),
          )),
          const SizedBox(height: LGGap.lg),

          Entrance(index: 4, child: GreyPanel(
            padding: const EdgeInsets.fromLTRB(LGGap.edge, LGGap.md, LGGap.edge, LGGap.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: LGGap.md),
                Text('Condition', style: LGText.headline(context)),
                ImpactBar(
                  icon: CupertinoIcons.heart_fill,
                  label: 'Happiness',
                  value: '${(stats.happiness * 100).round()}%',
                  fraction: stats.happiness,
                  color: LGColor.resolve(LGColor.burn, context),
                ),
                ImpactBar(
                  icon: CupertinoIcons.bolt_fill,
                  label: 'Energy',
                  value: '${(stats.energy * 100).round()}%',
                  fraction: stats.energy,
                  color: effort,
                ),
                ImpactBar(
                  icon: CupertinoIcons.leaf_arrow_circlepath,
                  label: 'Health',
                  value: '${(stats.health * 100).round()}%',
                  fraction: stats.health,
                  color: eco,
                ),
              ],
            ),
          )),
          const SizedBox(height: LGGap.lg),

          Entrance(index: 5, child: Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: CupertinoIcons.calendar,
                  value: '${stats.daysTogether}',
                  label: 'days together',
                  color: accent,
                ),
              ),
              const SizedBox(width: LGGap.lg),
              Expanded(
                child: _MiniStat(
                  icon: CupertinoIcons.leaf_arrow_circlepath,
                  value: savedKg.toStringAsFixed(0),
                  label: 'kg CO₂ raised on',
                  color: eco,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    return GlassSurface(
      radius: LGRadius.md,
      dense: true,
      padding: const EdgeInsets.all(LGGap.edge),
      shadows: LGShadow.low(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: LGGap.lg),
          Text(value, style: LGText.mono(context, size: 22, weight: FontWeight.w700)),
          const SizedBox(height: LGGap.xxs),
          Text(label, style: LGText.caption1(context).copyWith(color: secondary)),
        ],
      ),
    );
  }
}

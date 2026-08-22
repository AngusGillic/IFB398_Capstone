import 'package:flutter/cupertino.dart';

import '../data/user_data.dart';
import '../ui/entrance.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';
import 'impact_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);
    final data = AppData.current;

    return AppShell(
      showBottomNav: true,
      selectedIndex: 2,
      padding: EdgeInsets.zero,
      child: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(
          LGGap.edge,
          MediaQuery.paddingOf(context).top + LGGap.section,
          LGGap.edge,
          MediaQuery.paddingOf(context).bottom + AppShell.navHeight + LGGap.section,
        ),
        children: [
          Entrance(index: 0, child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_greeting, John', style: LGText.largeTitle(context)),
                    const SizedBox(height: LGGap.xxs),
                    Text(
                      "Let's get green",
                      style: LGText.subhead(context).copyWith(color: secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LGGap.xl),
              GlassIconButton(
                icon: CupertinoIcons.bell_fill,
                semanticLabel: 'Notifications',
                size: 40,
                iconSize: 17,
                onPressed: () {},
              ),
            ],
          )),
          const SizedBox(height: LGGap.section),
          Entrance(index: 1, child: GreyPanel(
            onTap: () => _open(context, const ImpactPage()),
            padding: const EdgeInsets.all(LGGap.edge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Impact this week', style: LGText.subhead(context)),
                    const Spacer(),
                    Icon(CupertinoIcons.chevron_right, size: 13,
                        color: LGColor.resolve(LGColor.tertiaryLabel, context)),
                  ],
                ),
                const SizedBox(height: LGGap.edge),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: GlassStat(
                        label: 'CO₂ saved',
                        value: '${data.week.co2SavedKg.toStringAsFixed(1)} kg',
                        icon: CupertinoIcons.leaf_arrow_circlepath,
                        color: LGColor.resolve(LGColor.eco, context),
                      ),
                    ),
                    Expanded(
                      child: GlassStat(
                        label: 'Trips',
                        value: '${data.week.trips}',
                        icon: CupertinoIcons.map_pin_ellipse,
                      ),
                    ),
                    const MiniGraph(),
                  ],
                ),
              ],
            ),
          )),
          const SizedBox(height: LGGap.edge),
          Entrance(index: 2, child: GreyPanel(
            padding: const EdgeInsets.all(LGGap.edge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suggested', style: LGText.subhead(context)),
                const SizedBox(height: LGGap.lg),
                for (var i = 0; i < data.suggestions.length; i++) ...[
                  if (i > 0)
                    Container(
                      height: 0.33,
                      margin: const EdgeInsets.symmetric(vertical: LGGap.lg),
                      color: LGColor.resolve(LGColor.separator, context),
                    ),
                  _SuggestedRow(trip: data.suggestions[i]),
                ],
              ],
            ),
          )),
          const SizedBox(height: LGGap.edge),
          Entrance(index: 3, child: MintPanel(
            padding: const EdgeInsets.all(LGGap.edge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.flame_fill, size: 15,
                        color: LGColor.resolve(LGColor.eco, context)),
                    const SizedBox(width: LGGap.sm),
                    Text('Challenge progress', style: LGText.headline(context)),
                  ],
                ),
                const SizedBox(height: LGGap.lg),
                Text(data.challenge.title, style: LGText.subhead(context)),
                const SizedBox(height: LGGap.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          '${data.challenge.daysDone} of ${data.challenge.daysTotal} days',
                          style: LGText.caption1(context).copyWith(color: secondary)),
                    ),
                    Text(
                        '${data.challenge.steps} / ${data.challenge.stepGoal} steps',
                        style: LGText.caption1(context).copyWith(color: secondary)),
                  ],
                ),
                const SizedBox(height: LGGap.lg),
                GlassProgress(value: data.challenge.progress),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _SuggestedRow extends StatelessWidget {
  const _SuggestedRow({required this.trip});

  final SuggestedTrip trip;

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);
    final accent = LGColor.resolve(LGColor.accent, context);

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: ShapeDecoration(
            color: accent.withValues(alpha: 0.16),
            shape: LGShape.border(LGRadius.xs),
          ),
          child: Icon(CupertinoIcons.briefcase_fill, color: accent, size: 16),
        ),
        const SizedBox(width: LGGap.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trip.label,
                  style: LGText.subhead(context).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: LGGap.xxs),
              Text('${trip.durationMinutes} min · ${trip.mode}',
                  style: LGText.caption1(context).copyWith(color: secondary)),
            ],
          ),
        ),
        const SizedBox(width: LGGap.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${trip.co2SavedKg.toStringAsFixed(1)} kg',
                style: LGText.mono(context, size: 14)),
            const SizedBox(height: LGGap.xxs),
            Text('leave ${trip.leaveAt}',
                style: LGText.caption2(context).copyWith(color: secondary)),
          ],
        ),
      ],
    );
  }
}

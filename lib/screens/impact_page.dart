import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/user_data.dart';
import '../ui/entrance.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/charts.dart';

import '../screens/home_page.dart';

class ImpactPage extends StatefulWidget {
  const ImpactPage({super.key});

  @override
  State<ImpactPage> createState() => _ImpactPageState();
}

class _ImpactPageState extends State<ImpactPage> {
  ImpactRange _range = ImpactRange.week;
  int? _selectedColumn;

  ImpactSeries get _data => AppData.current.seriesFor(_range);

  String _goalMessage(ImpactSeries series) {
    if (series.goalKg <= 0) return 'Set a goal to track your progress.';
    final remaining = series.goalKg - series.co2SavedKg;
    if (remaining <= 0) {
      return 'You have passed your ${_range.periodNoun} goal.';
    }
    return '${remaining.toStringAsFixed(1)} kg to reach your '
        '${_range.periodNoun} goal.';
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final eco = LGColor.resolve(LGColor.eco, context);
    final transit = LGColor.resolve(LGColor.transit, context);
    final accent = LGColor.resolve(LGColor.accent, context);
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    final modeColors = <String, Color>{
      'Transit': transit,
      'Walking': eco,
      'Cycling': LGColor.resolve(LGColor.effort, context),
    };

    final modeIcons = <String, IconData>{
      'Transit': CupertinoIcons.bus,
      'Walking': CupertinoIcons.person_fill,
      'Cycling': CupertinoIcons.gauge,
    };

    final series = _data;
    final modeTotal = series.byMode.values.fold<double>(0, (a, b) => a + b);
    final progress = series.goalProgress;

    return AppShell(
      showBottomNav: true,
      selectedIndex: 1,
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
          Entrance(
            index: 0, 
            child: BackTitle(
              title: 'Your impact', 
              onBackTap: () {
                _open(context, const HomePage());
              }
            )
          ),

          Entrance(index: 1, child: GlassSegmented<ImpactRange>(
            groupValue: _range,
            children: {for (final r in ImpactRange.values) r: r.label},
            onChanged: (r) => setState(() {
              _range = r;
              _selectedColumn = null;
            }),
          )),
          const SizedBox(height: LGGap.section),

          Entrance(index: 2, child: Center(
            child: RingGauge(
              progress: progress,
              size: 208,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountUpText(
                    value: series.co2SavedKg,
                    suffix: ' kg',
                    style: LGText.largeTitle(context).copyWith(fontSize: 40),
                  ),
                  Text('CO₂ saved',
                      style: LGText.subhead(context).copyWith(color: secondary)),
                  const SizedBox(height: LGGap.md),
                  GlassPill(
                    label: '${(progress * 100).round()}% of goal',
                    color: eco,
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: LGGap.section),

          Entrance(index: 3, child: Row(
            children: [
              Expanded(
                child: _EquivalenceCard(
                  icon: CupertinoIcons.leaf_arrow_circlepath,
                  value: series.treeDays.toStringAsFixed(0),
                  unit: 'tree-days',
                  caption: 'of carbon absorbed',
                  color: eco,
                ),
              ),
              const SizedBox(width: LGGap.lg),
              Expanded(
                child: _EquivalenceCard(
                  icon: CupertinoIcons.car_detailed,
                  value: series.kmNotDriven.toStringAsFixed(1),
                  unit: 'km',
                  caption: 'not driven',
                  color: accent,
                ),
              ),
            ],
          )),
          const SizedBox(height: LGGap.lg),

          Entrance(index: 4, child: GreyPanel(
            padding: const EdgeInsets.all(LGGap.edge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _range == ImpactRange.week ? 'Daily saving' : 'Saving over time',
                      style: LGText.headline(context),
                    ),
                    const Spacer(),
                    if (_selectedColumn != null)
                      Text(
                        '${series.valueAt(_selectedColumn!).toStringAsFixed(2)} kg',
                        style: LGText.mono(context, size: 15).copyWith(color: eco),
                      )
                    else if (series.goalPerColumn != null)
                      Text(
                        'Goal ${series.goalPerColumn!.toStringAsFixed(2)} kg each',
                        style: LGText.caption1(context).copyWith(color: secondary),
                      ),
                  ],
                ),
                const SizedBox(height: LGGap.edge),
                WeekBars(
                  values: series.values,
                  labels: series.labels,
                  goal: series.goalPerColumn,
                  selectedIndex: _selectedColumn,
                  onSelect: (i) => setState(
                      () => _selectedColumn = _selectedColumn == i ? null : i),
                ),
              ],
            ),
          )),
          const SizedBox(height: LGGap.lg),

          Entrance(index: 5, child: GreyPanel(
            padding: const EdgeInsets.all(LGGap.edge),
            child: Row(
              children: [
                DonutChart(
                  size: 118,
                  stroke: 18,
                  slices: [
                    ChartSlice(label: 'Green', value: series.greenKm, color: eco),
                    ChartSlice(
                      label: 'Driven',
                      value: series.drivenKm,
                      color: LGColor.resolve(LGColor.burn, context),
                    ),
                  ],
                  centre: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(series.greenShare * 100).round()}%',
                          style: LGText.title3(context)),
                      Text('green',
                          style: LGText.caption2(context).copyWith(color: secondary)),
                    ],
                  ),
                ),
                const SizedBox(width: LGGap.section),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('How you travelled', style: LGText.headline(context)),
                      const SizedBox(height: LGGap.lg),
                      _LegendRow(
                        color: eco,
                        label: 'Green modes',
                        value: '${series.greenKm.toStringAsFixed(1)} km',
                      ),
                      const SizedBox(height: LGGap.md),
                      _LegendRow(
                        color: LGColor.resolve(LGColor.burn, context),
                        label: 'Driving',
                        value: '${series.drivenKm.toStringAsFixed(1)} km',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: LGGap.lg),

          Entrance(index: 6, child: GreyPanel(
            padding: const EdgeInsets.fromLTRB(LGGap.edge, LGGap.md, LGGap.edge, LGGap.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: LGGap.md),
                Text('Where it came from', style: LGText.headline(context)),
                for (final entry in series.byMode.entries)
                  ImpactBar(
                    icon: modeIcons[entry.key] ?? CupertinoIcons.circle,
                    label: entry.key,
                    value: '${entry.value.toStringAsFixed(1)} kg',
                    fraction: modeTotal <= 0 ? 0 : entry.value / modeTotal,
                    color: modeColors[entry.key] ?? accent,
                  ),
              ],
            ),
          )),
          const SizedBox(height: LGGap.lg),

          Entrance(index: 7, child: MintPanel(
            padding: const EdgeInsets.all(LGGap.edge),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: ShapeDecoration(
                    color: eco.withValues(alpha: 0.18),
                    shape: LGShape.border(LGRadius.sm),
                  ),
                  child: Icon(CupertinoIcons.arrow_up_right, color: eco, size: 20),
                ),
                const SizedBox(width: LGGap.edge),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        series.changeVsPrevious == 0
                            ? 'No change on last ${_range.periodNoun}'
                            : '${(series.changeVsPrevious.abs() * 100).round()}% '
                                '${series.changeVsPrevious > 0 ? 'more' : 'less'} '
                                'than last ${_range.periodNoun}',
                        style: LGText.subhead(context).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: LGGap.xxs),
                      Text(
                        _goalMessage(series),
                        style: LGText.caption1(context).copyWith(color: secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: LGGap.edge),
          Entrance(index: 8, child: Text(
            'Savings are measured against the same trips made by petrol car '
            '(0.17 kg CO₂ per km).',
            textAlign: TextAlign.center,
            style: LGText.caption2(context).copyWith(color: secondary),
          )),
        ],
      ),
    );
  }
}

class _EquivalenceCard extends StatelessWidget {
  const _EquivalenceCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.caption,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String unit;
  final String caption;
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
          Icon(icon, size: 18, color: color),
          const SizedBox(height: LGGap.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LGText.mono(context, size: 24, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: LGGap.xs),
              Text(unit, style: LGText.caption1(context).copyWith(color: secondary)),
            ],
          ),
          const SizedBox(height: LGGap.xxs),
          Text(caption, style: LGText.caption1(context).copyWith(color: secondary)),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: ShapeDecoration(color: color, shape: const CircleBorder()),
        ),
        const SizedBox(width: LGGap.lg),
        Expanded(child: Text(label, style: LGText.footnote(context))),
        Text(value, style: LGText.mono(context, size: 13)),
      ],
    );
  }
}

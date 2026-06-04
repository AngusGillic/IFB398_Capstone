import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import 'past_journeys_page.dart';
import 'steps_page.dart';
import 'transportation_stats_page.dart';

class WeeklyStatsPage extends StatelessWidget {
  const WeeklyStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(2, 42, 2, 100),
        children: [
          const BackTitle(title: 'Weekly Stats'),
          const SizedBox(height: 14),
          const _WeekDots(),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _StatTile('Steps', '7800', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StepsPage()))),
              _StatTile('Distance traveled', '12km', () {}),
              _StatTile('Temperature type', '◔', () {}),
              _StatTile('CO2 emissions saved', '4000g', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransportationStatsPage()))),
              _StatTile('Place holder', '▰▰▰', () {}),
              _StatTile('Past Journeys', '9', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PastJourneysPage()))),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekDots extends StatelessWidget {
  const _WeekDots();

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(10, (i) => CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Text('${i + 1}', style: const TextStyle(fontSize: 9)))));
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _StatTile(this.title, this.value, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: GreyPanel(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)), const SizedBox(height: 10), Text(value, style: const TextStyle(fontSize: 25, color: AppColors.green, fontWeight: FontWeight.w900))])));
  }
}

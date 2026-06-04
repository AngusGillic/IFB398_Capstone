import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';

class TripActivePage extends StatelessWidget {
  const TripActivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(2, 38, 2, 100),
        children: [
          const Text('20 min      12:00      700m', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const GreyPanel(child: Text('Destination RLS, Destination st,\nVia Bus & Walking', style: TextStyle(fontWeight: FontWeight.w800))),
          const GreyPanel(child: Text('Next Stop\n200m\nTurn Right onto Green St\n━━━━━━━━━━━━●', style: TextStyle(fontWeight: FontWeight.w800))),
          const SizedBox(height: 250, child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(16)), child: PlaceholderMap())),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context), child: const Text('Stop'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.green), onPressed: () {}, child: const Text('Report Incident'))),
          ]),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';

class PastJourneysPage extends StatelessWidget {
  const PastJourneysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(2, 42, 2, 100),
        children: [
          const BackTitle(title: 'Past Journeys'),
          const SizedBox(height: 14),
          const SizedBox(height: 190, child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(16)), child: PlaceholderMap())),
          const SizedBox(height: 10),
          const GreyPanel(child: Text('Journey Information\nLocation:\nTransport:\nCO2:\nTime:\nPlaceholder:')),
          ...List.generate(9, (i) => GreyPanel(child: Text('Journey ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }
}

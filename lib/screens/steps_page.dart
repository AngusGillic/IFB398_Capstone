import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';

class StepsPage extends StatelessWidget {
  const StepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(2, 42, 2, 100),
        children: const [
          BackTitle(title: 'Steps'),
          SizedBox(height: 14),
          GreyPanel(child: SizedBox(height: 180, child: _Bars())),
          SizedBox(height: 10),
          Row(children: [Expanded(child: GreyPanel(child: Text('Goal\n10,000'))), SizedBox(width: 8), Expanded(child: GreyPanel(child: Text('Placeholder')))]),
          SizedBox(height: 10),
          GreyPanel(child: Text('Placeholder')),
        ],
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars();

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [80.0, 120.0, 145.0, 92.0, 132.0].map((h) => Container(width: 34, height: h, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)))).toList());
  }
}

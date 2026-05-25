import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';

class TransportationStatsPage extends StatelessWidget {
  const TransportationStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(2, 42, 2, 100),
        children: const [
          BackTitle(title: 'Transportation'),
          SizedBox(height: 18),
          GreyPanel(child: SizedBox(height: 245, child: _Donut())),
        ],
      ),
    );
  }
}

class _Donut extends StatelessWidget {
  const _Donut();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 190,
        height: 190,
        child: Stack(alignment: Alignment.center, children: const [
          CircularProgressIndicator(value: 0.78, strokeWidth: 18, color: Color(0xFFC46E00), backgroundColor: Color(0xFFEDEDED)),
          Text('2,567\n/\n10,000', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(6, 50, 6, 100),
        children: [
          const BackTitle(title: 'Your Impact', trailing: 'This week⌄'),
          const SizedBox(height: 36),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  CircularProgressIndicator(value: 0.72, strokeWidth: 8, color: AppColors.green, backgroundColor: Color(0xFFCFEFD2)),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    TravellyLogo(size: 44),
                    SizedBox(height: 7),
                    Text('2.4kg', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                    Text('CO2 saved', style: TextStyle(fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text("That's like", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
          const Text('🌿 Planting 1 Tree', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const Text('and keeping it alive for a day!!', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
          const SizedBox(height: 24),
          GreyPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Impact Breakdown', style: TextStyle(fontWeight: FontWeight.w900)),
                Divider(color: Colors.grey),
                _ImpactLine(icon: Icons.directions_bus, title: 'Public Transport', value: '1.8kg'),
                _ImpactLine(icon: Icons.directions_walk, title: 'Walking', value: '0.4kg'),
                _ImpactLine(icon: Icons.directions_bike, title: 'Cycling', value: '0.2kg'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const GreyPanel(child: Text('Compare with last week\n+38% more CO2 saved', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _ImpactLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ImpactLine({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 9, bottom: 9),
      child: Row(
        children: [
          CircleAvatar(radius: 17, backgroundColor: Colors.grey.shade300, child: Icon(icon, color: Colors.grey.shade600, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          SizedBox(width: 110, child: LinearProgressIndicator(value: title == 'Public Transport' ? 0.8 : 0.35, color: AppColors.green, backgroundColor: Colors.grey.shade300)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

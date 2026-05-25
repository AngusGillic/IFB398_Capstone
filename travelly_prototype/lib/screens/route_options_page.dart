import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';
import 'saved_co2_page.dart';
import 'trip_active_page.dart';

class RouteOptionsPage extends StatelessWidget {
  const RouteOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 3,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Positioned.fill(child: PlaceholderMap()),
          Positioned(
            top: 66,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const GreyPanel(child: Text('From    Street, City, State\nTo      Street, City, State', style: TextStyle(fontWeight: FontWeight.w800))),
                const SizedBox(height: 10),
                GreyPanel(
                  child: Column(
                    children: [
                      _RouteLine('Greenest Route', 'Estimated 0.8kg CO2', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedCo2Page()))),
                      const Divider(),
                      _RouteLine('Fastest Route', 'Arrival 10 mins • 2.1kg CO2', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripActivePage()))),
                      const Divider(),
                      _RouteLine('Scenic Route', 'Estimated 1.1kg CO2', () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RouteLine(this.title, this.subtitle, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(onTap: onTap, leading: const Icon(Icons.eco, color: AppColors.green), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.check_circle, color: AppColors.green));
  }
}

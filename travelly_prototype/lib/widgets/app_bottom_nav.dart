import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/map_page.dart';
import '../screens/pet_selection_page.dart';
import '../screens/weekly_stats_page.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNav({super.key, required this.selectedIndex});

  void _replace(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.settings, const WeeklyStatsPage()),
      (Icons.park, const WeeklyStatsPage()),
      (Icons.home, const HomePage()),
      (Icons.location_on, const MapPage()),
      (Icons.pets, const PetSelectionPage()),
    ];

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.navGrey.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => _replace(context, items[index].$2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 56 : 42,
              height: selected ? 56 : 42,
              decoration: BoxDecoration(
                color: selected ? Colors.grey.shade500 : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                items[index].$1,
                color: selected ? Colors.white : Colors.grey.shade600,
                size: selected ? 32 : 27,
              ),
            ),
          );
        }),
      ),
    );
  }
}

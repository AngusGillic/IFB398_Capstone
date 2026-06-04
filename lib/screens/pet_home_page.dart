import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';
import 'activities_page.dart';
import 'pet_profile_page.dart';

class PetHomePage extends StatelessWidget {
  const PetHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 4,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(2, 35, 2, 100),
        children: [
          const Align(alignment: Alignment.centerRight, child: Text('🪙 200', style: TextStyle(fontWeight: FontWeight.w900))),
          const SizedBox(height: 10),
          Container(
            height: 225,
            decoration: BoxDecoration(color: const Color(0xFFEFF7FF), borderRadius: BorderRadius.circular(20)),
            child: Stack(
              children: const [
                Positioned(left: 35, top: 30, child: Icon(Icons.cabin, size: 95, color: Colors.orange)),
                Positioned(right: 55, top: 70, child: PlaceholderPet(size: 86)),
                Positioned(left: 20, bottom: 24, child: Icon(Icons.local_florist, size: 44, color: AppColors.green)),
                Positioned(right: 15, bottom: 22, child: Icon(Icons.yard, size: 68, color: AppColors.greenDark)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GreyPanel(
            radius: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActivitiesPage())), child: const Text('Activities', style: TextStyle(fontWeight: FontWeight.w900))),
                    GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PetProfilePage())), child: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w900))),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 11,
                  crossAxisSpacing: 11,
                  children: const [
                    _Action(icon: Icons.local_florist, label: 'small pot'),
                    _Action(icon: Icons.grass, label: 'plant'),
                    _Action(icon: Icons.yard, label: 'plant'),
                    _Action(icon: Icons.park, label: 'plant'),
                    _Action(icon: Icons.home, label: 'house'),
                    _Action(icon: Icons.image, label: 'placeholder'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Action({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(13)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: AppColors.green), const SizedBox(height: 5), Text(label, style: const TextStyle(fontSize: 10))]),
    );
  }
}

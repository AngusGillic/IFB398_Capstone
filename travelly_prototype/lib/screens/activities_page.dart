import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 4,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(2, 42, 2, 100),
        children: [
          const BackTitle(title: 'Activities', trailing: '🪙 200'),
          const SizedBox(height: 16),
          const Row(children: [Chip(label: Text('All')), SizedBox(width: 6), Chip(label: Text('Daily')), SizedBox(width: 6), Chip(label: Text('Care')), SizedBox(width: 6), Chip(label: Text('Training'))]),
          const SizedBox(height: 12),
          ...List.generate(6, (_) => const _ActivityRow()),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow();

  @override
  Widget build(BuildContext context) {
    return GreyPanel(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.grey.shade300, child: const Icon(Icons.directions_walk, color: Colors.grey)),
          const SizedBox(width: 12),
          const Expanded(child: Text('Walk\n20min', style: TextStyle(fontWeight: FontWeight.w900))),
          const Text('+10XP\n+100 coins', textAlign: TextAlign.right, style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

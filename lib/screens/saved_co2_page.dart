import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_panels.dart';
import '../widgets/mock_painters.dart';

class SavedCo2Page extends StatelessWidget {
  const SavedCo2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showBottomNav: true,
      selectedIndex: 3,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Positioned.fill(child: PlaceholderMap()),
          const Positioned(
            bottom: 105,
            left: 22,
            right: 22,
            child: GreyPanel(
              child: Text('You Could save 1.8kg CO2', textAlign: TextAlign.center, style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

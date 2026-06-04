import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'phone_notch.dart';
import 'app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final bool showNotch;
  final bool showBottomNav;
  final int selectedIndex;
  final EdgeInsets padding;

  const AppShell({
    super.key,
    required this.child,
    this.showNotch = true,
    this.showBottomNav = false,
    this.selectedIndex = 2,
    this.padding = const EdgeInsets.fromLTRB(18, 18, 18, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: child,
            ),
            if (showNotch)
              const Positioned(top: 0, left: 0, right: 0, child: PhoneNotch()),
            if (showBottomNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppBottomNav(selectedIndex: selectedIndex),
              ),
          ],
        ),
      ),
    );
  }
}

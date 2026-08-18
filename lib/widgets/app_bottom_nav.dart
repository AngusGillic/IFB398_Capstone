import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../screens/home_page.dart';
import '../screens/impact_page.dart';
import '../screens/map_page.dart';
import '../screens/pet_selection_page.dart';
import '../screens/settings_page.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';

/// Floating tab bar, inset from the screen edges.
class AppBottomNav extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNav({super.key, required this.selectedIndex});

  static const _items = <({IconData icon, String label})>[
    (icon: CupertinoIcons.gear_alt_fill, label: 'Settings'),
    (icon: CupertinoIcons.leaf_arrow_circlepath, label: 'Impact'),
    (icon: CupertinoIcons.house_fill, label: 'Home'),
    (icon: CupertinoIcons.location_fill, label: 'Map'),
    (icon: CupertinoIcons.heart_fill, label: 'Pet'),
  ];

  Widget _pageFor(int index) => switch (index) {
        0 => const SettingsPage(),
        1 => const ImpactPage(),
        2 => const HomePage(),
        3 => const MapPage(),
        _ => const PetSelectionPage(),
      };

  void _select(BuildContext context, int index) {
    if (index == selectedIndex) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _pageFor(index),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: LGMotion.fast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = LGColor.resolve(LGColor.accent, context);
    final inactive = LGColor.resolve(LGColor.secondaryLabel, context);

    return GlassSurface(
      height: 64,
      radius: 32,
      blur: LGGlass.blurHeavy,
      dense: true,
      padding: const EdgeInsets.symmetric(horizontal: LGGap.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_items.length, (index) {
          final selected = index == selectedIndex;
          final item = _items[index];

          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              label: item.label,
              child: GlassTappable(
                haptic: false,
                scale: 0.88,
                onTap: () => _select(context, index),
                child: SizedBox(
                  height: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: LGMotion.medium,
                        curve: LGMotion.standard,
                        padding: const EdgeInsets.symmetric(
                            horizontal: LGGap.xl, vertical: LGGap.sm),
                        decoration: ShapeDecoration(
                          color: selected
                              ? accent.withValues(alpha: 0.16)
                              : const Color(0x00000000),
                          shape: LGShape.border(LGRadius.pill),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: selected ? accent : inactive,
                        ),
                      ),
                      const SizedBox(height: LGGap.xxs),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LGText.caption2(context).copyWith(
                          fontSize: 9,
                          color: selected ? accent : inactive,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

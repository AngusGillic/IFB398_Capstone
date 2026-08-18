import 'package:flutter/cupertino.dart';

import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import 'app_bottom_nav.dart';

/// Page shell: backdrop, full-bleed content, and the floating tab bar.
class AppShell extends StatelessWidget {
  final Widget child;
  final bool showNotch;
  final bool showBottomNav;
  final int selectedIndex;
  final EdgeInsets padding;
  final bool backdrop;

  const AppShell({
    super.key,
    required this.child,
    this.showNotch = true,
    this.showBottomNav = false,
    this.selectedIndex = 2,
    this.padding = const EdgeInsets.fromLTRB(LGGap.edge, LGGap.edge, LGGap.edge, 0),
    this.backdrop = true,
  });

  /// Height the tab bar occupies.
  static const double navHeight = 64;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    Widget content = Padding(padding: padding, child: child);

    if (backdrop) {
      content = GlassBackdrop(intensity: 0.9, child: content);
    }

    return CupertinoPageScaffold(
      backgroundColor: LGColor.resolve(LGColor.canvas, context),
      child: Stack(
        children: [
          Positioned.fill(child: content),
          if (showBottomNav)
            Positioned(
              left: LGGap.xl,
              right: LGGap.xl,
              bottom: bottomInset + LGGap.md,
              child: AppBottomNav(selectedIndex: selectedIndex),
            ),
        ],
      ),
    );
  }
}

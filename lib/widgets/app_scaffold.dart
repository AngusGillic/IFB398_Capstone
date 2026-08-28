import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui/glass.dart';
import '../ui/glass_widgets.dart';
import 'app_bottom_nav.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Page shell: backdrop, full-bleed content, and the floating tab bar.
class AppShell extends StatelessWidget {
  final Widget child;
  final bool showNotch;
  final bool showBottomNav;
  final int selectedIndex;
  final EdgeInsets padding;
  final bool backdrop;
  // Added this attribute to allow loading screen to fully cover the screen
  final bool loading;

  const AppShell({
    super.key,
    required this.child,
    this.showNotch = true,
    this.showBottomNav = false,
    this.selectedIndex = 2,
    this.padding = const EdgeInsets.fromLTRB(LGGap.edge, LGGap.edge, LGGap.edge, 0),
    this.backdrop = true,
    // Added this attribute to allow loading screen to fully cover the screen
    this.loading = false,
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
      // Added 'resizeToAvoidBottomInset:false' to avoid "Bottom overflowed by 1.2 pixels" error
      resizeToAvoidBottomInset: false,
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
          // This will manifest based on the setState function that manipulates the attributes 
          // during runtime.
          if (loading == true) 
            Positioned.fill(
              child: 
              Container(
                width: double.infinity,
                color: Colors.black.withAlpha(85),
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(color: const Color.fromARGB(255, 40, 223, 46), size: 70)
                ),
              )
            )
        ],
      ),
    );
  }
}

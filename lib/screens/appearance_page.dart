import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../ui/app_theme.dart';
import '../ui/glass.dart';
import '../ui/glass_widgets.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Appearance',
      scrollable: true,
      child: ValueListenableBuilder<AppThemeMode>(
        valueListenable: ThemeController.instance,
        builder: (context, mode, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Preview(),
              const SizedBox(height: LGGap.section),
              GlassSection(
                header: 'Theme',
                footer: 'Automatic follows your device between light and dark.',
                children: [
                  for (final option in AppThemeMode.values)
                    GlassRow(
                      title: option.label,
                      subtitle: option.detail,
                      icon: option.icon,
                      chevron: false,
                      trailing: option == mode
                          ? Icon(
                              CupertinoIcons.check_mark,
                              size: 18,
                              color: LGColor.resolve(LGColor.accent, context),
                            )
                          : null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ThemeController.instance.set(option);
                      },
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Live sample of the glass material against the current theme, so the choice
/// is visible without leaving the screen.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final accent = LGColor.resolve(LGColor.accent, context);
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    return GlassSurface(
      radius: LGRadius.lg,
      dense: true,
      padding: const EdgeInsets.all(LGGap.edge),
      shadows: LGShadow.low(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: ShapeDecoration(
                  color: accent.withValues(alpha: 0.16),
                  shape: LGShape.border(LGRadius.xs),
                ),
                child: Icon(CupertinoIcons.leaf_arrow_circlepath, size: 16, color: accent),
              ),
              const SizedBox(width: LGGap.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Preview',
                        style: LGText.subhead(context)
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text('How surfaces look',
                        style: LGText.caption1(context).copyWith(color: secondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LGGap.edge),
          Row(
            children: [
              GlassPill(label: 'Walking', color: LGColor.resolve(LGColor.eco, context)),
              const SizedBox(width: LGGap.sm),
              GlassPill(label: 'Bus 150', color: LGColor.resolve(LGColor.transit, context)),
              const SizedBox(width: LGGap.sm),
              GlassPill(label: '24 min', color: accent),
            ],
          ),
        ],
      ),
    );
  }
}

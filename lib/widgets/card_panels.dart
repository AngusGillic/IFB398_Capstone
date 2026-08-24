import 'package:flutter/cupertino.dart';

import '../ui/glass.dart';
import '../ui/glass_widgets.dart';

/// Standard content panel.
class GreyPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double radius;
  final VoidCallback? onTap;

  const GreyPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(LGGap.xl),
    this.margin = EdgeInsets.zero,
    this.radius = LGRadius.md,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = GlassSurface(
      radius: radius,
      margin: margin,
      padding: padding,
      dense: true,
      shadows: LGShadow.low(context),
      child: child,
    );

    return onTap == null ? panel : GlassTappable(onTap: onTap, child: panel);
  }
}

/// Accent-tinted panel for highlighted content.
class MintPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;

  const MintPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(LGGap.edge),
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = GlassSurface(
      radius: LGRadius.md,
      margin: margin,
      padding: padding,
      tint: LGColor.resolve(LGColor.eco, context).withValues(alpha: 0.14),
      shadows: LGShadow.low(context),
      child: child,
    );

    return onTap == null ? panel : GlassTappable(onTap: onTap, child: panel);
  }
}

class IosField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool obscure;
  final IconData? trailing;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  // Added onChanged for dynamic input field tracking, used for Form Validation
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTrailingTap;

  const IosField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.obscure = false,
    this.trailing,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    final trailingIcon = trailing == null
        ? null
        : GlassTappable(
            haptic: false,
            scale: 0.85,
            onTap: onTrailingTap,
            child: Icon(trailing, size: 18, color: secondary),
          );

    if (controller != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: LGGap.xl),
        child: GlassField(
          controller: controller!,
          placeholder: label,
          icon: icon,
          obscure: obscure,
          keyboardType: keyboardType,
          suffix: trailingIcon,
          onChanged: onChanged,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: LGGap.xl),
      child: GlassSurface(
        radius: LGRadius.sm,
        blur: LGGlass.blurLight,
        padding: const EdgeInsets.symmetric(horizontal: LGGap.xl, vertical: LGGap.lg),
        shadows: LGShadow.low(context),
        child: Row(
          children: [
            Icon(icon, size: 18, color: secondary),
            const SizedBox(width: LGGap.xl),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: LGText.caption2(context).copyWith(color: secondary),
                  ),
                  const SizedBox(height: LGGap.xxs),
                  Text(
                    obscure ? '••••••••' : value,
                    style: LGText.subhead(context).copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}

/// Primary action button.
class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;

  const GreenButton({
    super.key,
    required this.text,
    required this.onTap,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton(label: text, onPressed: onTap, loading: loading, icon: icon);
  }
}

/// Secondary action button.
class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;

  const GhostButton({super.key, required this.text, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      label: text,
      onPressed: onTap,
      icon: icon,
      style: GlassButtonStyle.tinted,
    );
  }
}

/// In-page header with a back chevron, for screens without a navigation bar.
class BackTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const BackTitle({super.key, required this.title, this.trailing, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    final accent = LGColor.resolve(LGColor.accent, context);
    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.only(bottom: LGGap.edge),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: canPop
                ? GlassTappable(
                    haptic: false,
                    scale: 0.88,
                    onTap: () => Navigator.maybePop(context),
                    child: Icon(CupertinoIcons.back, size: 26, color: accent),
                  )
                : null,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LGText.headline(context),
            ),
          ),
          SizedBox(
            width: 44,
            child: trailing == null
                ? null
                : GlassTappable(
                    haptic: false,
                    onTap: onTrailingTap,
                    child: Text(
                      trailing!,
                      textAlign: TextAlign.right,
                      style: LGText.subhead(context).copyWith(color: accent),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

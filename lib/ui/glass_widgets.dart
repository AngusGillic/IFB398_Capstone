import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'glass.dart';

class _RimPainter extends CustomPainter {
  const _RimPainter({
    required this.radius,
    required this.bright,
    required this.dim,
    required this.width,
  });
  final double radius;
  final Color bright;
  final Color dim;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (rect.isEmpty) return;
    final inset = rect.deflate(width / 2);
    if (inset.isEmpty) return;
    final path = LGShape.path(inset, radius - width / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bright, bright.withValues(alpha: bright.a * 0.25), dim],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(inset);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RimPainter old) =>
      old.radius != radius || old.bright != bright || old.dim != dim || old.width != width;
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = LGRadius.lg,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.blur = LGGlass.blurStandard,
    this.tint,
    this.dense = false,
    this.rim = true,
    this.shadows,
    this.width,
    this.height,
    this.alignment,
    this.clipBehind = true,
  });
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double blur;
  final Color? tint;
  final bool dense;
  final bool rim;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final bool clipBehind;

  @override
  Widget build(BuildContext context) {
    final resolvedTint = tint ??
        LGColor.resolve(dense ? LGColor.glassTintDense : LGColor.glassTint, context);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(color: resolvedTint),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: LGGlass.sheen(context)),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (clipBehind) {
      content = BackdropFilter(
        filter: LGGlass.filter(blur: blur),
        child: content,
      );
    }

    Widget lens = ClipRSuperellipse(
      borderRadius: LGShape.radius(radius),
      child: content,
    );

    if (rim) {
      lens = CustomPaint(
        foregroundPainter: _RimPainter(
          radius: radius,
          bright: LGColor.resolve(LGColor.glassRimBright, context),
          dim: LGColor.resolve(LGColor.glassRimDim, context),
          width: 1.0,
        ),
        child: lens,
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(

        borderRadius: LGShape.radius(radius),
        boxShadow: shadows ?? LGShadow.floating(context),
      ),
      child: lens,
    );
  }
}

class GlassTappable extends StatefulWidget {
  const GlassTappable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.96,
    this.haptic = true,
    this.enabled = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool haptic;
  final bool enabled;

  @override
  State<GlassTappable> createState() => _GlassTappableState();
}

class _GlassTappableState extends State<GlassTappable> {
  bool _down = false;
  bool get _active => widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _set(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _active ? (_) => _set(true) : null,
      onTapUp: _active ? (_) => _set(false) : null,
      onTapCancel: _active ? () => _set(false) : null,
      onTap: _active
          ? () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap?.call();
            }
          : null,
      onLongPress: _active
          ? () {
              if (widget.haptic) HapticFeedback.mediumImpact();
              widget.onLongPress?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: _down ? LGMotion.fast : LGMotion.medium,
        curve: LGMotion.press,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.4,
          duration: LGMotion.fast,
          child: widget.child,
        ),
      ),
    );
  }
}

class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({
    super.key,
    required this.child,
    this.animate = false,
    this.intensity = 1.0,
    this.seedColors,
  });

  final Widget child;

  /// Unused. Present so existing call sites keep compiling.
  final bool animate;

  final double intensity;
  final List<Color>? seedColors;

  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: LGColor.resolve(LGColor.canvas, context)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.85),
              radius: 1.15,
              colors: [
                (dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
                    .withValues(alpha: (dark ? 0.05 : 0.035) * intensity),
                const Color(0x00000000),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(LGGap.xl),
    this.margin = EdgeInsets.zero,
    this.radius = LGRadius.lg,
    this.tint,
    this.selected = false,
    this.blur = LGGlass.blurStandard,
    this.dense = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color? tint;
  final bool selected;
  final double blur;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final accent = LGColor.resolve(LGColor.accent, context);

    return GlassTappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: LGMotion.medium,
        curve: LGMotion.standard,
        margin: margin,
        foregroundDecoration: selected
            ? ShapeDecoration(
                shape: LGShape.border(
                  radius,
                  side: BorderSide(color: accent, width: 2),
                ),
              )
            : null,
        child: GlassSurface(
          radius: radius,
          padding: padding,
          blur: blur,
          dense: dense,
          tint: tint ??
              (selected ? accent.withValues(alpha: 0.14) : null),
          child: child,
        ),
      ),
    );
  }
}

enum GlassButtonStyle {
  filled,

  tinted,

  plain,

  destructive,
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.style = GlassButtonStyle.filled,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GlassButtonStyle style;
  final bool loading;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final accent = LGColor.resolve(LGColor.accent, context);
    final danger = LGColor.resolve(LGColor.burn, context);
    late final Color fg;
    late final Color? solidFill;
    late final Color? glassTint;

    switch (style) {
      case GlassButtonStyle.filled:
        fg = CupertinoColors.white;
        solidFill = accent;
        glassTint = null;
      case GlassButtonStyle.destructive:
        fg = CupertinoColors.white;
        solidFill = danger;
        glassTint = null;
      case GlassButtonStyle.tinted:
        fg = accent;
        solidFill = null;
        glassTint = accent.withValues(alpha: 0.16);
      case GlassButtonStyle.plain:
        fg = LGColor.resolve(LGColor.label, context);
        solidFill = null;
        glassTint = null;
    }

    final height = compact ? 36.0 : 50.0;
    final radius = height / 2;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          CupertinoActivityIndicator(radius: compact ? 7 : 9, color: fg)
        else ...[
          if (icon != null) ...[
            Icon(icon, size: compact ? 15 : 18, color: fg),
            const SizedBox(width: LGGap.sm),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (compact ? LGText.subhead(context) : LGText.headline(context))
                  .copyWith(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
    Widget body;
    if (solidFill != null) {
      body = Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: compact ? LGGap.xl : LGGap.section),
        decoration: ShapeDecoration(
          color: enabled ? solidFill : solidFill.withValues(alpha: 0.4),
          shape: LGShape.border(radius),
          shadows: enabled
              ? [
                  BoxShadow(
                    color: solidFill.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: content,
      );
    } else {
      body = GlassSurface(
        height: height,
        radius: radius,
        blur: LGGlass.blurLight,
        tint: glassTint,
        padding: EdgeInsets.symmetric(horizontal: compact ? LGGap.xl : LGGap.section),
        shadows: LGShadow.low(context),
        child: Center(child: content),
      );
    }

    if (expand) body = SizedBox(width: double.infinity, child: body);
    return GlassTappable(enabled: enabled, onTap: onPressed, child: body);
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.color,
    this.tint,
    this.semanticLabel,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? tint;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GlassTappable(
        onTap: onPressed,
        scale: 0.9,
        child: GlassSurface(
          width: size,
          height: size,
          radius: size / 2,
          blur: LGGlass.blurLight,
          tint: tint,
          dense: true,
          alignment: Alignment.center,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: color ?? LGColor.resolve(LGColor.label, context),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
    this.filled = false,
  });
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LGColor.resolve(LGColor.accent, context);
    final fg = filled ? CupertinoColors.white : c;

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: LGGap.md, vertical: LGGap.xs),
      decoration: ShapeDecoration(
        color: filled ? c : c.withValues(alpha: 0.14),
        shape: LGShape.border(
          LGRadius.pill,
          side: filled ? BorderSide.none : BorderSide(color: c.withValues(alpha: 0.24), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: LGGap.xs),
          ],
          Text(
            label,
            style: LGText.caption2(context).copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return onTap == null ? pill : GlassTappable(onTap: onTap, child: pill);
  }
}

class GlassField extends StatelessWidget {
  const GlassField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.error,
    this.autocorrect = true,
    this.enabled = true,
    this.onSubmitted,
    this.suffix,
    this.autofillHints,
    this.maxLines = 1,
    this.focusNode,
  });
  final FocusNode? focusNode;
  final TextEditingController controller;
  final String placeholder;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? error;
  final bool autocorrect;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final Iterable<String>? autofillHints;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final danger = LGColor.resolve(LGColor.burn, context);
    final hasError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        DecoratedBox(
          decoration: ShapeDecoration(
            color: LGColor.resolve(LGColor.fill, context),
            shape: LGShape.border(
              LGRadius.sm,
              side: hasError
                  ? BorderSide(color: danger.withValues(alpha: 0.6), width: 1)
                  : BorderSide(
                      color: LGColor.resolve(LGColor.separator, context)
                          .withValues(alpha: 0.35),
                      width: 0.5,
                    ),
            ),
          ),
          child: CupertinoTextField(
            controller: controller,
            focusNode: focusNode,
            placeholder: placeholder,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autocorrect: autocorrect,
            enabled: enabled,
            onSubmitted: onSubmitted,
            autofillHints: autofillHints,
            maxLines: obscure ? 1 : maxLines,
            padding: const EdgeInsets.symmetric(horizontal: LGGap.xl, vertical: 13),
            style: LGText.body(context),
            placeholderStyle: LGText.body(context)
                .copyWith(color: LGColor.resolve(LGColor.tertiaryLabel, context)),
            prefix: icon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: LGGap.xl),
                    child: Icon(
                      icon,
                      size: 18,
                      color: LGColor.resolve(LGColor.secondaryLabel, context),
                    ),
                  ),
            suffix: suffix == null
                ? null
                : Padding(padding: const EdgeInsets.only(right: LGGap.lg), child: suffix),

            decoration: null,
          ),
        ),
        AnimatedSize(
          duration: LGMotion.fast,
          curve: LGMotion.standard,
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: LGGap.sm, left: LGGap.xs),
                  child: Text(
                    error!,
                    style: LGText.caption1(context).copyWith(color: danger),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class GlassNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  const GlassNavBar({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.showBack = true,
    this.transparent = false,
    this.middle,
  });
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool showBack;
  final bool transparent;
  final Widget? middle;
  static const double _barHeight = 44;

  @override
  Size get preferredSize => const Size.fromHeight(_barHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    final bar = SizedBox(
      height: _barHeight + top,
      child: Padding(
        padding: EdgeInsets.only(top: top, left: LGGap.xs, right: LGGap.xs),
        child: NavigationToolbar(
          leading: leading ??
              (showBack && canPop
                  ? GlassTappable(
                      onTap: () => Navigator.of(context).maybePop(),
                      scale: 0.88,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: LGGap.md),
                        child: Icon(
                          CupertinoIcons.back,
                          size: 26,
                          color: LGColor.resolve(LGColor.accent, context),
                        ),
                      ),
                    )
                  : null),
          middle: middle ??
              (title == null
                  ? null
                  : Text(
                      title!,
                      style: LGText.headline(context),
                      overflow: TextOverflow.ellipsis,
                    )),
          trailing: trailing,
          centerMiddle: true,
        ),
      ),
    );
    if (transparent) return bar;

    return ClipRect(
      child: BackdropFilter(
        filter: LGGlass.filter(blur: LGGlass.blurHeavy),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: LGColor.resolve(LGColor.glassTint, context),
            border: Border(
              bottom: BorderSide(
                color: LGColor.resolve(LGColor.separator, context).withValues(alpha: 0.5),
                width: 0.33,
              ),
            ),
          ),
          child: bar,
        ),
      ),
    );
  }
}

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.trailing,
    this.backdrop = true,
    this.animateBackdrop = true,
    this.navBar = true,
    this.padding,
    this.scrollable = false,
  });
  final Widget child;
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool backdrop;
  final bool animateBackdrop;
  final bool navBar;
  final EdgeInsets? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + (navBar ? 44 : 0);
    Widget body = child;

    if (scrollable) {
      body = CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: (padding ?? const EdgeInsets.symmetric(horizontal: LGGap.edge))
                .add(EdgeInsets.only(
              top: topInset + LGGap.md,
              bottom: MediaQuery.paddingOf(context).bottom + LGGap.section,
            )),
            sliver: SliverToBoxAdapter(child: body),
          ),
        ],
      );
    } else if (padding != null) {
      body = Padding(padding: padding!, child: body);
    }

    if (backdrop) {
      body = GlassBackdrop(animate: animateBackdrop, child: body);
    }

    return CupertinoPageScaffold(
      backgroundColor: LGColor.resolve(LGColor.canvas, context),
      navigationBar: navBar
          ? GlassNavBar(title: title, leading: leading, trailing: trailing)
          : null,
      child: body,
    );
  }
}

class GlassSection extends StatelessWidget {
  const GlassSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.margin = const EdgeInsets.only(bottom: LGGap.section),
  });
  final List<Widget> children;
  final String? header;
  final String? footer;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final separator = LGColor.resolve(LGColor.separator, context);

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(left: LGGap.edge, bottom: LGGap.sm, right: LGGap.edge),
              child: Text(
                header!.toUpperCase(),
                style: LGText.caption1(context).copyWith(
                  color: LGColor.resolve(LGColor.secondaryLabel, context),
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          GlassSurface(
            radius: LGRadius.md,
            dense: true,
            shadows: LGShadow.low(context),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Padding(

                      padding: const EdgeInsets.only(left: LGGap.edge),
                      child: Container(height: 0.33, color: separator),
                    ),
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(
                  left: LGGap.edge, right: LGGap.edge, top: LGGap.md),
              child: Text(
                footer!,
                style: LGText.caption1(context).copyWith(
                  color: LGColor.resolve(LGColor.secondaryLabel, context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GlassRow extends StatelessWidget {
  const GlassRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.chevron = true,
    this.destructive = false,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final danger = LGColor.resolve(LGColor.burn, context);
    final fg = destructive ? danger : LGColor.resolve(LGColor.label, context);
    final tint = iconColor ?? LGColor.resolve(LGColor.accent, context);

    return GlassTappable(
      onTap: onTap,
      scale: 0.99,
      haptic: false,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: LGGap.xl, vertical: LGGap.lg),
        child: Row(
          children: [
            if (icon != null) ...[

              Container(
                width: 28,
                height: 28,
                decoration: ShapeDecoration(
                  color: destructive ? danger : tint,
                  shape: LGShape.border(7),
                ),
                child: Icon(icon, size: 17, color: CupertinoColors.white),
              ),
              const SizedBox(width: LGGap.xl),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: LGText.body(context).copyWith(color: fg)),
                  if (subtitle != null) ...[
                    const SizedBox(height: LGGap.xxs),
                    Text(
                      subtitle!,
                      style: LGText.footnote(context).copyWith(
                        color: LGColor.resolve(LGColor.secondaryLabel, context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: LGGap.md),
              DefaultTextStyle(
                style: LGText.body(context).copyWith(
                  color: LGColor.resolve(LGColor.secondaryLabel, context),
                ),
                child: trailing!,
              ),
            ],
            if (onTap != null && chevron) ...[
              const SizedBox(width: LGGap.sm),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: LGColor.resolve(LGColor.tertiaryLabel, context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GlassStat extends StatelessWidget {
  const GlassStat({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.compact = false,
  });
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LGColor.resolve(LGColor.accent, context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: compact ? 15 : 18, color: c),
          const SizedBox(height: LGGap.xs),
        ],
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LGText.mono(context, size: compact ? 16 : 19, weight: FontWeight.w700),
        ),
        const SizedBox(height: LGGap.xxs),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LGText.caption2(context).copyWith(
            color: LGColor.resolve(LGColor.secondaryLabel, context),
          ),
        ),
      ],
    );
  }
}

class GlassEmpty extends StatelessWidget {
  const GlassEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: LGGap.section, vertical: LGGap.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: LGColor.resolve(LGColor.tertiaryLabel, context)),
            const SizedBox(height: LGGap.xl),
            Text(title, style: LGText.headline(context), textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: LGGap.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: LGText.subhead(context).copyWith(
                  color: LGColor.resolve(LGColor.secondaryLabel, context),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: LGGap.section),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  double maxHeightFactor = 0.88,
  bool grabber = true,
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    barrierColor: const Color(0x33000000),
    builder: (context) => _GlassSheetShell(
      title: title,
      grabber: grabber,
      maxHeightFactor: maxHeightFactor,
      child: Builder(builder: builder),
    ),
  );
}

class _GlassSheetShell extends StatelessWidget {
  const _GlassSheetShell({
    required this.child,
    this.title,
    this.grabber = true,
    this.maxHeightFactor = 0.88,
  });
  final Widget child;
  final String? title;
  final bool grabber;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * maxHeightFactor),
        child: GlassSurface(
          radius: LGRadius.xxl,
          blur: LGGlass.blurHeavy,
          dense: true,
          margin: const EdgeInsets.all(LGGap.md),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (grabber) const GlassGrabber(),
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        LGGap.edge, LGGap.xs, LGGap.edge, LGGap.xl),
                    child: Text(title!, style: LGText.title3(context)),
                  ),
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassGrabber extends StatelessWidget {
  const GlassGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LGGap.md),
      child: Center(
        child: Container(
          width: 36,
          height: 5,
          decoration: ShapeDecoration(
            color: LGColor.resolve(LGColor.tertiaryLabel, context),
            shape: LGShape.border(LGRadius.pill),
          ),
        ),
      ),
    );
  }
}

Future<void> showGlassAlert(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'OK',
}) {
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: message == null
          ? null
          : Padding(padding: const EdgeInsets.only(top: LGGap.md), child: Text(message)),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

Future<bool> showGlassConfirm(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: message == null
          ? null
          : Padding(padding: const EdgeInsets.only(top: LGGap.md), child: Text(message)),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: destructive,
          isDefaultAction: !destructive,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showGlassToast(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? tint,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ToastHost(
      message: message,
      icon: icon,
      tint: tint,
      duration: duration,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
  HapticFeedback.selectionClick();
}

class _ToastHost extends StatefulWidget {
  const _ToastHost({
    required this.message,
    required this.duration,
    required this.onDone,
    this.icon,
    this.tint,
  });
  final String message;
  final Duration duration;
  final VoidCallback onDone;
  final IconData? icon;
  final Color? tint;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: LGMotion.medium);

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future<void>.delayed(widget.duration).then((_) async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: LGMotion.enter);

    return Positioned(
      left: LGGap.edge,
      right: LGGap.edge,
      top: MediaQuery.paddingOf(context).top + LGGap.md,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.6), end: Offset.zero).animate(curved),
          child: GlassSurface(
            radius: LGRadius.pill,
            blur: LGGlass.blurHeavy,
            dense: true,
            padding: const EdgeInsets.symmetric(horizontal: LGGap.edge, vertical: LGGap.xl),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon ?? CupertinoIcons.info_circle_fill,
                  size: 17,
                  color: widget.tint ?? LGColor.resolve(LGColor.accent, context),
                ),
                const SizedBox(width: LGGap.lg),
                Expanded(
                  child: Text(
                    widget.message,
                    style: LGText.subhead(context).copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassSegmented<T extends Object> extends StatelessWidget {
  const GlassSegmented({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onChanged,
  });
  final T groupValue;
  final Map<T, String> children;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: groupValue,
        backgroundColor: LGColor.resolve(LGColor.fill, context),
        thumbColor: LGColor.resolve(LGColor.grouped, context),
        padding: const EdgeInsets.all(2),
        onValueChanged: (v) {
          if (v == null) return;
          HapticFeedback.selectionClick();
          onChanged(v);
        },
        children: {
          for (final e in children.entries)
            e.key: Padding(
              padding: const EdgeInsets.symmetric(vertical: LGGap.sm),
              child: Text(
                e.value,
                style: LGText.subhead(context).copyWith(
                  fontWeight: e.key == groupValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
        },
      ),
    );
  }
}

class GlassLoader extends StatelessWidget {
  const GlassLoader({super.key, this.message, this.radius = 14});
  final String? message;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoActivityIndicator(radius: radius),
          if (message != null) ...[
            const SizedBox(height: LGGap.xl),
            Text(
              message!,
              style: LGText.footnote(context).copyWith(
                color: LGColor.resolve(LGColor.secondaryLabel, context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GlassProgress extends StatelessWidget {
  const GlassProgress({
    super.key,
    required this.value,
    this.color,
    this.height = 10,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LGColor.resolve(LGColor.eco, context);

    return ClipRSuperellipse(
      borderRadius: LGShape.radius(LGRadius.pill),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: LGColor.resolve(LGColor.fill, context)),
            ),
            FractionallySizedBox(
              widthFactor: value.isFinite ? value.clamp(0.0, 1.0) : 0.0,
              child: AnimatedContainer(
                duration: LGMotion.slow,
                curve: LGMotion.standard,
                decoration: ShapeDecoration(
                  color: c,
                  shape: LGShape.border(LGRadius.pill),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

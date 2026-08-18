import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../ui/glass.dart';

class ChartSlice {
  const ChartSlice({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;
}

/// Circular gauge, sweeping from the top.
class RingGauge extends StatelessWidget {
  const RingGauge({
    super.key,
    required this.progress,
    required this.child,
    this.size = 190,
    this.stroke = 14,
    this.color,
  });

  final double progress;
  final Widget child;
  final double size;
  final double stroke;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LGColor.resolve(LGColor.eco, context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0),
      duration: const Duration(milliseconds: 900),
      curve: LGMotion.enter,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: value,
            stroke: stroke,
            color: c,
            track: LGColor.resolve(LGColor.fill, context),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.stroke,
    required this.color,
    required this.track,
  });

  final double progress;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final centre = rect.center;
    final radius = (size.shortestSide - stroke) / 2;
    final arcRect = Rect.fromCircle(center: centre, radius: radius);

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [color.withValues(alpha: 0.55), color],
        ).createShader(arcRect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}

/// Donut showing how a total splits.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    this.size = 132,
    this.stroke = 22,
    this.centre,
  });

  final List<ChartSlice> slices;
  final double size;
  final double stroke;
  final Widget? centre;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: LGMotion.enter,
      builder: (context, t, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _DonutPainter(
            slices: slices,
            stroke: stroke,
            sweep: t,
            empty: LGColor.resolve(LGColor.fill, context),
          ),
          child: centre == null ? null : Center(child: centre),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.slices,
    required this.stroke,
    required this.sweep,
    required this.empty,
  });

  final List<ChartSlice> slices;
  final double stroke;
  final double sweep;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: (Offset.zero & size).center, radius: radius);
    final total = slices.fold<double>(0, (a, s) => a + s.value);

    if (total <= 0) {
      canvas.drawCircle(
        rect.center,
        radius,
        Paint()
          ..color = empty
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      return;
    }

    const gap = 0.035;
    var start = -math.pi / 2;

    for (final slice in slices) {
      if (slice.value <= 0) continue;
      final extent = (slice.value / total) * 2 * math.pi * sweep;
      if (extent <= gap) continue;

      canvas.drawArc(
        rect,
        start + gap / 2,
        extent - gap,
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke,
      );
      start += extent;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.sweep != sweep || old.slices != slices;
}

/// Bar chart with an optional goal line. Bars are tappable.
class WeekBars extends StatelessWidget {
  const WeekBars({
    super.key,
    required this.values,
    required this.labels,
    this.goal,
    this.selectedIndex,
    this.onSelect,
    this.height = 150,
    this.color,
  });

  final List<double> values;
  final List<String> labels;
  final double? goal;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LGColor.resolve(LGColor.eco, context);
    final track = LGColor.resolve(LGColor.fill, context);
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No trips yet',
            style: LGText.caption1(context).copyWith(color: secondary),
          ),
        ),
      );
    }

    final peak = values.fold<double>(0, math.max);
    final ceiling = math.max(peak, goal ?? 0) * 1.15;
    final safeCeiling = ceiling <= 0 ? 1.0 : ceiling;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          if (goal != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 22 + (height - 22) * (goal! / safeCeiling),
              child: CustomPaint(
                painter: _DashedLinePainter(color: secondary.withValues(alpha: 0.4)),
                child: const SizedBox(height: 1),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final selected = selectedIndex == i;
              final factor = (values[i] / safeCeiling).clamp(0.0, 1.0);

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSelect == null ? null : () => onSelect!(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: factor),
                        duration: Duration(milliseconds: 500 + i * 60),
                        curve: LGMotion.enter,
                        builder: (context, t, _) => Container(
                          height: (height - 26) * t,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: ShapeDecoration(
                            color: selected ? c : c.withValues(alpha: 0.42),
                            shape: LGShape.border(LGRadius.xs),
                          ),
                        ),
                      ),
                      const SizedBox(height: LGGap.sm),
                      Text(
                        i < labels.length ? labels[i] : '',
                        style: LGText.caption2(context).copyWith(
                          color: selected ? LGColor.resolve(LGColor.label, context) : secondary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (values.every((v) => v == 0))
            Positioned.fill(
              child: Center(
                child: Text(
                  'No trips yet',
                  style: LGText.caption1(context).copyWith(color: secondary),
                ),
              ),
            ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(height: 0.5, color: track),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dash = 4.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + dash, size.width), 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => old.color != color;
}

/// Label, value and a proportional fill bar.
class ImpactBar extends StatelessWidget {
  const ImpactBar({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final double fraction;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final secondary = LGColor.resolve(LGColor.secondaryLabel, context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LGGap.lg),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: ShapeDecoration(
              color: color.withValues(alpha: 0.16),
              shape: LGShape.border(LGRadius.xs),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: LGGap.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: LGText.subhead(context).copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(value, style: LGText.mono(context, size: 15)),
                  ],
                ),
                const SizedBox(height: LGGap.sm),
                ClipRSuperellipse(
                  borderRadius: LGShape.radius(LGRadius.pill),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ColoredBox(color: LGColor.resolve(LGColor.fill, context)),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                              begin: 0,
                              end: fraction.isFinite ? fraction.clamp(0.0, 1.0) : 0.0),
                          duration: const Duration(milliseconds: 700),
                          curve: LGMotion.enter,
                          builder: (context, t, _) => FractionallySizedBox(
                            widthFactor: t,
                            child: ColoredBox(color: color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: LGGap.xs),
                  Text(trailing!,
                      style: LGText.caption2(context).copyWith(color: secondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Counts up to [value] on first build.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.style,
    this.decimals = 1,
    this.suffix = '',
  });

  final double value;
  final TextStyle style;
  final int decimals;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.isFinite ? value : 0.0),
      duration: const Duration(milliseconds: 900),
      curve: LGMotion.enter,
      builder: (context, v, _) =>
          Text('${v.toStringAsFixed(decimals)}$suffix', style: style),
    );
  }
}

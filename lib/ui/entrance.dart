import 'dart:async';

import 'package:flutter/cupertino.dart';

/// Fades and lifts a widget into place. Siblings with increasing [index]
/// arrive in sequence. Skipped when reduce-motion is on.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.index = 0,
    this.stagger = const Duration(milliseconds: 45),
    this.duration = const Duration(milliseconds: 420),
    this.offset = 14,
    this.scaleFrom = 1.0,
  });

  final Widget child;
  final int index;
  final Duration stagger;
  final Duration duration;

  /// Distance travelled upward, in logical pixels.
  final double offset;

  /// Below 1 to also scale up on entry.
  final double scaleFrom;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = widget.stagger * widget.index;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    final curved = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
    );

    Widget result = FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0, widget.offset / 100),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );

    if (widget.scaleFrom != 1.0) {
      result = ScaleTransition(
        scale: Tween(begin: widget.scaleFrom, end: 1.0).animate(curved),
        child: result,
      );
    }

    return result;
  }
}

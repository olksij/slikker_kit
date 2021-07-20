import 'dart:math';

import 'package:flutter/widgets.dart';

/// Elastic-based curve.
/// - [period] is the duration of the oscillation.
/// - [smthns] decides how smooth animation is. Highes values means bigger amplitude.
class SlikkerCurve extends ElasticOutCurve {
  /// The duration of the oscillation.
  final double period;

  /// Decides how smooth animation is. Highes values means bigger amplitude.
  final double smthns;

  final bool _forward;

  SlikkerCurve({
    this.smthns = 8,
    this.period = 0.6,
  }) : _forward = true;

  SlikkerCurve.reverse({
    this.smthns = 8,
    this.period = 0.6,
  }) : _forward = false;

  @override
  double transformInternal(double t) {
    if (!_forward) t = 1 - t;
    final num base = pow(2, -smthns * t);
    final double curve = sin((t - period / 4) * (pi * 2) / period);
    return _forward ? base * curve + 1 : -base * curve;
  }
}

/// A controller with an applied curve for an animation
class SlikkerAnimationController {
  /// A controller with an applied curve for an animation
  SlikkerAnimationController({
    required TickerProvider vsync,
    required this.curve,
    this.reverseCurve,
    Duration duration = const Duration(seconds: 0),
    double value = 0.0,
  }) {
    this._duration = duration;
    controller = AnimationController(
      vsync: vsync,
      duration: duration,
      value: value,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  /// The curve to use in forward direction.
  final Curve curve;

  /// The curve to use in reverse direction.
  ///
  /// If null, [curve.flipped] is used.
  final Curve? reverseCurve;

  /// A controller for an animation.
  late final AnimationController controller;

  /// An animation that applies a curve to [controller].
  late final CurvedAnimation animation;

  /// Is the length of time this animation should last.
  late Duration _duration;

  /// Direction of the animation.
  bool _forward = true;

  /// Represents was animation called already or not.
  ///
  /// If [_called] is `false`, it does mean that animation is waiting till
  /// [value] reached `1.0` or `0.0`, so animation can go to another
  bool _called = false;

  /// The current value of the animation.
  double get value => animation.value;

  set duration(Duration duration) {
    controller.duration = duration;
    this._duration = duration;
    if (controller.isAnimating)
      _forward ? controller.forward() : controller.reverse();
  }

  /// Release the resources used by this object.
  void dispose() => controller.dispose();

  /// Starts running this animation till the end. [forward] decides
  /// direction of the animation.
  ///
  /// If the animation hasn't reached the end (value 0.0 or 1.0)
  /// and this method was called, animation
  /// quickly gets to the end, and goes to another.
  void run(bool forward, {Duration? duration, bool? end}) {
    //if (this._forward == forward) return;

    duration ??= this._duration;

    controller.duration = Duration(
      milliseconds: duration.inMilliseconds ~/ 1.5,
    );

    double tillEnd = forward ? controller.value : 1 - controller.value;
    int wait = tillEnd * controller.duration!.inMilliseconds ~/ 1;

    if (end == true) wait = 0;

    this._forward = forward;
    this._called = false;

    Function() animate = () {
      if (this._forward != forward && this._called) return;
      _called = true;
      animation.curve = forward ? curve : reverseCurve ?? curve.flipped;
      controller.duration = duration;
      forward ? controller.forward(from: 0) : controller.reverse(from: 1);
    };

    if (wait == 0) animate();
    if (wait > 0) Future.delayed(Duration(milliseconds: wait), animate);
  }
}

import 'dart:math';
import 'dart:ui';

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
    this.duration = const Duration(seconds: 1),
  }) {
    _AnimationController _init(Curve curve) => _AnimationController(
        vsync: vsync, curve: curve, duration: duration, value: 0);

    forwardAnmt = _init(curve);
    reverseAnmt = _init(reverseCurve ?? curve.flipped);
    switchAnmt = _init(Curves.easeInOutCubic)
      ..duration = Duration(milliseconds: duration.inMilliseconds ~/ 10);
  }

  /// The curve to use in forward direction.
  final Curve curve;

  /// The curve to use in reverse direction.
  ///
  /// If null, [curve.flipped] is used.
  final Curve? reverseCurve;

  /// An animation controller for an forward animation.
  late final _AnimationController forwardAnmt;

  /// An animation controller for an reverse animation.
  late final _AnimationController reverseAnmt;

  /// An animation controller for an smooth animation switch between
  /// [forwardAnmt] and [reverseAnmt].
  late final _AnimationController switchAnmt;

  /// Is the length of time this animation should last.
  late Duration duration;

  /// Direction of the animation
  bool forward = true;

  /* /// Direction of the animation.
  bool _forward = true;

  /// Represents was animation called already or not.
  ///
  /// If [_called] is `false`, it does mean that animation is waiting till
  /// [value] reached `1.0` or `0.0`, so animation can go to another
  bool _called = false; */

  /// The current value of the animation.
  double get value =>
      lerpDouble(forwardAnmt.value, reverseAnmt.value, switchAnmt.value)!;

  Listenable get listenable => Listenable.merge(
      [forwardAnmt.animation, reverseAnmt.animation, switchAnmt.animation]);

  bool get isAnimating =>
      forwardAnmt.isAnimating ||
      reverseAnmt.isAnimating ||
      switchAnmt.isAnimating;

  /// Release the resources used by this object.
  void dispose() {
    forwardAnmt.dispose();
    reverseAnmt.dispose();
    switchAnmt.dispose();
  }

  /// Starts running this animation till the end.
  ///
  /// - [forward] decides direction of the animation.
  /// - [duration] sets the duration of animation, you wanna call.
  /// - [end] decides if animation will animate from the end. If `false`, it
  ///   will animate from the current value and [wait] will be set to `false` too.
  /// - [wait] tell animation should it wait till it reach end or not.
  ///
  /// __Note:__ If the animation hasn't reached the end (value `0.0` or `1.0`)
  /// and this method was called, animation quickly gets to the end, and
  /// goes to another.
  void run(bool forward, {Duration? duration}) {
    duration ??= this.duration;
    this.forward = forward;

    final Function() animate = () {
      if (forward != this.forward) return;
      if (forward) forwardAnmt.forward(from: 0, duration: duration);
      if (!forward) reverseAnmt.reverse(from: 1, duration: duration);
    };

    if (!isAnimating) {
      switchAnmt.value = forward ? 0 : 1;
      animate();
    } else {
      double _tillEnd = forward ? value : 1 - value;
      int _wait = _tillEnd * duration.inMilliseconds ~/ 1.5;
      // TODO: Fix [_wait] on forward -> forward.
      Future.delayed(Duration(milliseconds: _wait), () {
        switchAnmt.animateTo(forward ? 0 : 1);
        //switchAnmt.value = forward ? 0 : 1;

        animate();
      });
    }
  }
}

/// A controller with an applied curve for an animation
class _AnimationController {
  /// A controller with an applied curve for an animation
  _AnimationController({
    required TickerProvider vsync,
    required this.curve,
    required this.duration,
    double value = 0.0,
  }) {
    controller =
        AnimationController(vsync: vsync, duration: duration, value: value);
    animation = CurvedAnimation(
      curve: curve,
      parent: controller,
    );
  }

  /// The curve to use in forward direction.
  final Curve curve;

  /// Is the length of time this animation should last.
  final Duration duration;

  set duration(Duration duration) => controller.duration = duration;

  /// A controller for an animation.
  late final AnimationController controller;

  /// An animation that applies a curve to [controller].
  late final CurvedAnimation animation;

  /// The current value of the animation.
  double get value => animation.value;

  bool get isAnimating => controller.isAnimating;

  /// Sets the current value of the animation.
  set value(double value) => controller.value = value;

  /// Starts running this animation forwards (towards the end).
  void forward({double? from, Duration? duration}) {
    controller.duration = duration ?? this.duration;
    controller.forward(from: from);
  }

  /// Starts running this animation in reverse (towards the beginning).
  void reverse({double? from, Duration? duration}) {
    controller.duration = duration ?? this.duration;
    controller.reverse(from: from);
  }

  /// Drives the animation from its current value to target.
  void animateTo(double value) => controller.animateTo(value);

  /// Release the resources used by this object.
  void dispose() => controller.dispose();
}

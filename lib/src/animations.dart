import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

// TODO: DurationlessAnimations

/// Elastic-based curve.
/// - [period] is the duration of the oscillation.
/// - [smthns] decides how smooth animation is. Highes values means bigger amplitude.
class SlikkerCurve extends ElasticOutCurve {
  /// The duration of the oscillation.
  final double period;

  /// Decides how smooth animation is. Highes values means bigger amplitude.
  final double smthns;

  final bool _forward;

  const SlikkerCurve({
    this.smthns = 8,
    this.period = 0.6,
  }) : _forward = true;

  const SlikkerCurve.reverse({
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

// TODO: DurationlessAnimations

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

  /// The current value of the animation.
  double get value =>
      lerpDouble(forwardAnmt.value, reverseAnmt.value, switchAnmt.value)!;

  Listenable get listenable =>
      Listenable.merge([forwardAnmt, reverseAnmt, switchAnmt]);

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

    final int start = forward ? 0 : 1;

    final double tillEnd = (start - value).abs();
    final double wait = tillEnd * duration.inMilliseconds;

    //Future.delayed(Duration(milliseconds: wait), () {
    switchAnmt.animateTo(
      start.toDouble(),
      duration: Duration(milliseconds: wait ~/ 5),
    );
    //switchAnmt.value = forward ? 0 : 1;

    //if (forward != this.forward) return;
    if (forward) forwardAnmt.forward(from: 0, duration: duration);
    if (!forward) reverseAnmt.reverse(from: 1, duration: duration);
    //});
  }
}

/// A controller with an applied curve for an animation
class _AnimationController extends AnimationController {
  /// A controller with an applied curve for an animation
  _AnimationController({
    required TickerProvider vsync,
    required Duration duration,
    required this.curve,
    double value = 0.0,
  }) : super(vsync: vsync, duration: duration, value: value);

  /// The curve to use in forward direction.
  final Curve curve;

  // Sets duration for [AnimationController].
  @override
  set duration(Duration? duration) => super.duration ??= duration;

  /// The current value of the animation.
  @override
  double get value => curve.transform(super.value);

  /// Sets the current value of the animation.
  @override
  set value(double value) => super.value = value;

  /// Starts running this animation forwards (towards the end).
  @override
  TickerFuture forward({double? from, Duration? duration}) {
    super.duration = duration ?? this.duration;
    return super.forward(from: from);
  }

  /// Starts running this animation in reverse (towards the beginning).
  @override
  TickerFuture reverse({double? from, Duration? duration}) {
    super.duration = duration ?? this.duration;
    return super.reverse(from: from);
  }

  /// Drives the animation from its current value to target.
  @override
  TickerFuture animateTo(double value, {Duration? duration, Curve? curve}) =>
      super.animateTo(value, duration: duration);

  /// Release the resources used by this object.
  @override
  void dispose() => super.dispose();
}

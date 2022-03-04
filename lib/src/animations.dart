import 'dart:math';

import 'package:flutter/widgets.dart';

/// Smooth elastic customizable curve used in Slikker Design System.
class SlikkerCurve {
  /// Period of wave in curve.
  final double period;

  /// Lower the value, more rapid and catchy animation is.
  final double smoothness;

  /// Cached values that avoid additional computation for each evaluation.
  /// - [s] is for storing `1/4` of period
  /// - [pc] stands for period correction in [sin] function.
  final double s, pc;

  /// Static 60 degree for animation correction and avoiding unnecesary computation.
  static const double deg = pi / 3;

  /// Smooth elastic customizable curve used in Slikker Design System.
  ///
  /// Curve is designed for new declaration for every new gesture.
  /// That was done in such way cause every gesture in unique,
  /// and animation should be unique too.
  ///
  /// Passing gesture parameters to curve can negatively impact CPU.
  const SlikkerCurve({
    this.period = .6,
    this.smoothness = 8,
  })  : s = period / 4,
        pc = (2 * pi) / period;

  /// Argument [t] must be in range from `-1.0` to `1.0`,
  /// where `t.abs() == 1.0` is the endpoints of the animation,
  /// and `t == 0` is the middle point of the animation, value of which is `0.5`.
  double transform(double t) {
    assert(-1 <= t && t <= 1, 'value $t is outside of [-1, 1] range.');
    if (t.abs() == 1) return t / 2 + .5;
    return _transformInternal(t);
  }

  /// Transforms [t] into curve value.
  double _transformInternal(double t) {
    final num base = pow(2, t * smoothness * (t >= 0 ? -1 : 1));
    final double curve = sin((t - s) * pc + deg * (t >= 0 ? 1 : -1));
    return t >= 0 ? base * curve + 1 : -base * curve;
  }

  @override
  String toString() => 'SlikkerCurve(period: $period, smoothness: $smoothness)';
}

const SlikkerCurve curve = SlikkerCurve();

/// A controller with an applied curve for an animation.
class SlikkerAnimationController extends AnimationController {
  /// A controller with an applied curve for an animation
  SlikkerAnimationController({
    required TickerProvider vsync,
    // TODO: DURATION TO VELOCITY
    Duration? duration,
    double value = 0.0,
  }) : super(vsync: vsync, duration: duration, value: value, lowerBound: -1);

  /// The current value of the animation returned from curve.
  @override
  double get value => curve.transform(super.value);

  /// Returns visual value of the animation between `0.0` and `1.0`,
  /// where `0.0` is animation visually at the beginning,
  /// and `1.0` is animation visually finished.
  double get visual => max(min(super.value * 10 + .5, 1), 0);

  /// Method, which should be called every time gesture changes.
  /// - [forward] - when `true`, animation is driving to the end (`visual == 1`).
  /// - [velocity] - speed of finger or pointer, when gesture passed to controller.
  TickerFuture run(bool forward, {double? velocity}) {
    // TODO: [DESIGN] velocity and acceleration manipulation.
    super.duration = Duration(milliseconds: 1600);

    if (forward) return super.forward(from: max(super.value, -0.05));
    return super.reverse(from: min(super.value, 0.05));
  }
}

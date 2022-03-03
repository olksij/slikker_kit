import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

// TODO: DurationlessAnimations

const SlikkerCurve curve = SlikkerCurve();

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
  /// Declare a new curve with every new parameter.
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

  double _transformInternal(double t) {
    final num base = pow(2, t * smoothness * (t >= 0 ? -1 : 1));
    final double curve = sin((t - s) * pc + deg * (t >= 0 ? 1 : -1));
    return t >= 0 ? base * curve + 1 : -base * curve;
  }

  @override
  String toString() => 'SlikkerCurve(period: $period, smoothness: $smoothness)';
}

/// A controller with an applied curve for an animation
class SlikkerAnimationController extends AnimationController {
  /// A controller with an applied curve for an animation
  SlikkerAnimationController({
    required TickerProvider vsync,
    // TODO: DURATION TO VELOCITY
    Duration? duration,
    double value = 0.0,
  }) : super(
          vsync: vsync,
          duration: duration,
          value: value,
          lowerBound: -1,
        );

  /// The current value of the animation.
  @override
  double get value => curve.transform(super.value);

  TickerFuture run(bool forward, {double? velocity}) {
    // TODO: VELOCITY MANIPULATION
    super.duration = Duration(milliseconds: 1600);

    if (forward) return super.forward(from: max(super.value, -0.05));
    return super.reverse(from: min(super.value, 0.05));
  }
}

import 'dart:math';

import 'package:flutter/widgets.dart';

enum CurveType { curveIn, curveOut, curveInOut }

/// An ideally symetric oscillating curve that grows and then shrinks
/// in magnitude while overshooting its bounds used in Slikker Design System.
///
/// At it's core is ideally symetric curve with a range [-1, 1],
/// at which at the center (`t == 0`) curve equals to `0.5`.
///
/// Most of the animation movement is laying in a range -[start] <= value <= [start].
///
/// The curve is designed for new declaration for every new gesture.
/// That was done in such way cause every gesture in unique,
/// and animation should be unique too.
class SlikkerCurve extends Curve {
  /// Period of wave in curve.
  final double period;

  /// Lower the value, more rapid and catchy animation is.
  final double smoothness;

  /// Cached values that avoid additional computation for each evaluation.
  /// - [s] is for storing `1/4` of period
  /// - [pc] stands for period correction in [sin] function.
  final double s, pc;

  /// If specified, the curve will behave as a regular [Curve] class
  /// and adapt it's curve and input ranges to given type.
  final CurveType type;

  /// Static 60 degree for animation correction and avoiding unnecesary computation.
  static const double deg = pi / 3;

  /// An ideally symetric oscillating curve that grows and then shrinks
  /// in magnitude while overshooting its bounds used in Slikker Design System.
  ///
  /// At it's core is ideally symetric curve with a range [-1, 1],
  /// at which at the center (`t == 0`) curve equals to `0.5`.
  ///
  /// Most of the animation movement is laying in a range -[start] <= value <= [start].
  ///
  /// The curve is designed for new declaration for every new gesture.
  /// That was done in such way cause every gesture in unique,
  /// and animation should be unique too.
  const SlikkerCurve({
    this.period = 1,
    this.smoothness = 8,
    this.type = CurveType.curveOut,
  })  : s = period / 4,
        pc = (2 * pi) / period;

  /// Returns the value of the curve at point t.
  ///
  /// This function must ensure the following:
  /// - The value of [t] must be between `0.0` and `1.0`.
  /// - Values of `t = 0.0` and `t = 1.0` must be mapped to `0.0` and `1.0`, respectively.
  @override
  double transform(double t) {
    switch (type) {
      case CurveType.curveInOut:
        return compute(t * 2 - 1);
      case CurveType.curveOut:
        return compute(t - start);
      case CurveType.curveIn:
        return compute(-t + start);
    }
  }

  /// Returns a number, which indicates at which position curve visually starts & ends.
  ///
  /// [SlikkerCurve] at it's core is ideally symetric curve with a range [-1, 1],
  /// at which at the center (`t == 0`) curve equals to `0.5`.
  /// But it visually starts and ends earlier than `t.abs() == 1`.
  /// The main animation is ranging in `[-start, start]` points.
  // TODO: calculate curve startpoint.
  double get start => 0.0833;

  /// Argument [t] must be in range from `-1.0` to `1.0`.
  /// where `t.abs() == 1.0` is the endpoints of the animation,
  /// and `t == 0` is the middle point of the animation, value of which is `0.5`.
  double compute(double t) {
    assert(-1 <= t && t <= 1, 'value $t is outside of [-1, 1] range.');
    if (t.abs() == 1) return t / 2 + .5;
    return transformInternal(t);
  }

  /// Transforms [t] into curve value. [t] should be in range `-1.0 <= t <= 1.0`.
  /// Returns evaluated by raw curve [t] value.
  /// The curve is similar to [ElasticInOutCurve], but idealized and adapted for playback.
  @override
  double transformInternal(double t) {
    final num base = pow(2, t * smoothness * (t >= 0 ? -1 : 1));
    final double curve = sin((t - s) * pc + deg * (t >= 0 ? 1 : -1));
    return t >= 0 ? base * curve + 1 : -base * curve;
  }

  @override
  String toString() => 'SlikkerCurve(period: $period, smoothness: $smoothness)';
}

/// A controller with an applied curve for an animation.
class SlikkerAnimationController extends AnimationController {
  // TODO: Doc
  final SlikkerCurve curve;

  /// A controller with an applied curve for an animation
  ///
  /// You can pass a [SlikkerCurve] you want to create directly to [curve],
  /// or use these parameters:
  /// - period - Period for the [SlikkerCurve] that will be created
  /// - smoothness - the higher value, the lower Inertia of the object is.
  SlikkerAnimationController({
    required TickerProvider vsync,
    // TODO: DURATION TO VELOCITY
    Duration? duration,
    double value = -1,
    double period = 1,
    SlikkerCurve? curve,
    double smoothness = 8,
  })  : curve = curve ?? SlikkerCurve(period: period, smoothness: smoothness),
        super(vsync: vsync, duration: duration, value: value, lowerBound: -1);

  /// The current value of the animation returned from curve.
  @override
  double get value => curve.compute(super.value);

  /// Returns visual value of the animation between `0.0` and `1.0`,
  /// where `0.0` is animation visually at the beginning,
  /// and `1.0` is animation visually finished.
  ///
  /// This is implemented since the animation usually visually
  /// finished earlier than it's whole duration.
  double get visual => max(min(super.value * 10 + .5, 1), 0);

  /// Method, which should be called every time gesture changes.
  /// - [forward] - when `true`, animation is driving to the end (`visual == 1`).
  /// - [velocity] - speed of finger or pointer, when gesture passed to controller.
  TickerFuture run(bool forward, {double? velocity}) {
    // TODO: [DESIGN] velocity and acceleration manipulation.
    super.duration = super.duration ?? const Duration(milliseconds: 1200);

    if (forward) return super.forward(from: max(super.value, -0.05));
    return super.reverse(from: min(super.value, 0.05));
  }
}

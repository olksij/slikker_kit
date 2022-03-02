import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

// TODO: DurationlessAnimations

const SlikkerCurve curve = SlikkerCurve();

class SlikkerCurve extends Curve {
  final bool forward;

  get reverse => const SlikkerCurve(forward: false);

  const SlikkerCurve({this.forward = true});

  @override
  double transformInternal(double t) {
    t = t / 0.95 - .05;
    if (!forward) t = 1 - t;
    final double period = .6;
    final double s = period / 4;
    final num smthns = 8;

    final num base = pow(2, -smthns * t);
    final double curve = sin((t - period / 4) * ((2 * pi) / period) + pi / 3);

    return forward ? base * curve + 1 : -base * curve;
  }
}

/// A controller with an applied curve for an animation
class SlikkerAnimationController extends AnimationController {
  /// A controller with an applied curve for an animation
  SlikkerAnimationController({
    required TickerProvider vsync,
    // TODO: DURATION TO VELOCITY
    Duration? duration,
    double value = 0.0,
  }) : super(vsync: vsync, duration: duration, value: value);

  bool _forward = true;

  /// The current value of the animation.
  @override
  double get value {
    //curve.transform(super.value) > .9 ? print(curve.transform(super.value)) : 0;
    return (_forward ? curve : curve.reverse).transform(super.value);
  }

  TickerFuture run(bool forward, {double? velocity}) {
    // TODO: VELOCITY MANIPULATION
    super.duration = Duration(milliseconds: 600);

    _forward = forward;

    //print('--');

    if (forward) return super.forward(from: max(super.value, 0));
    return super.reverse(from: min(super.value, 1));
  }
}

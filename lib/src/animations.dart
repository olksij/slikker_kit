import 'package:flutter/widgets.dart';
import 'dart:math';

enum AnimationDirection { forward, reverse }

class SlikkerCurve extends Curve {
  final double period;
  final double smthns;
  final AnimationDirection direction;

  SlikkerCurve.init({
    this.direction = AnimationDirection.forward,
    this.smthns = 8,
    this.period = 0.6,
  });

  @override
  double transformInternal(double t) {
    final int sign = direction == AnimationDirection.forward ? -1 : 1;
    final num base = pow(2, -smthns * sign * t);
    final num curve = sin((t - period / 4) * (pi * 2) / period);
    return base * curve * sign + sign == -1 ? 1 : 0;
  }
}

class SlikkerAnimationController {
  final Duration duration;
  final SlikkerCurveFields forwardFields;
  final SlikkerCurveFields? reverseFields;

  late AnimationController controller;
  CurvedAnimation? animation;

  SlikkerAnimationController({
    required TickerProvider vsync,
    required this.forwardFields,
    this.reverseFields,
    this.duration = const Duration(seconds: 0),
    double value = 0.0,
  }) {
    controller = AnimationController(
      vsync: vsync,
      duration: duration,
      value: value,
    );
    // TODO: Implement [animation] initialization.
  }

  // TODO: BUG. Animation return 0 or 1;
  double get value => (animation != null) ? animation!.value : 0;

  Listenable? get listenable => animation;

  void forward([bool value = true]) {
    if (!value) {
      reverse();
      return;
    }
    controller.duration = Duration(milliseconds: 100);
    Future.delayed(
      Duration(milliseconds: (controller.value * 100).toInt()),
      () {
        animation = CurvedAnimation(
          parent: controller,
          curve: SlikkerCurve.init(
            direction: AnimationDirection.forward,
            smthns: forwardFields.smthns,
            period: forwardFields.period,
          ),
        );
        controller.duration = duration;
        controller.forward();
      },
    );
  }

  void reverse() {
    controller.duration = Duration(milliseconds: 100);
    Future.delayed(
      Duration(milliseconds: (100 - controller.value * 100).toInt()),
      () {
        animation = CurvedAnimation(
          parent: controller,
          curve: SlikkerCurve.init(
            direction: AnimationDirection.forward,
            smthns: reverseFields?.smthns ?? forwardFields.smthns,
            period: reverseFields?.period ?? forwardFields.period,
          ),
        );
        controller.duration = duration;
        controller.reverse();
      },
    );
  }

  void dispose() => controller.dispose();
}

class SlikkerCurveFields {
  final double period, smthns;
  const SlikkerCurveFields({this.smthns = 8, this.period = 0.6});
}

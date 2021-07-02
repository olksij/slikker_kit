import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:slikker_kit/slikker_kit.dart';
import 'ripple.dart';

class SlikkerButton extends StatefulWidget {
  /// The Hue which will be used for your button. Expected value from 0.0 to 360.0
  final double accent;

  /// If [minor] is true, element lowers by z axis, becoming less noticable.
  ///
  /// Can be used to hint user for another suggested action.
  final bool minor;

  /// Whether the button is enabled or disabled.
  final bool disabled;

  /// If non-null, the corners of this box are rounded by this [BorderRadiusGeometry] value.
  final BorderRadius borderRadius;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// The empty space that surrounds the card inside.
  final EdgeInsetsGeometry? padding;

  /// The empty space that surrounds the card inside.
  final EdgeInsetsGeometry? margin;

  /// The [Function] that will be invoked on user's tap.
  final Function? onTap;

  @override
  _SlikkerButtonState createState() => _SlikkerButtonState();

  SlikkerButton({
    this.accent = 240,
    this.minor = false,
    this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.disabled = false,
    this.padding,
    this.margin,
  });
}

class _SlikkerButtonState extends State<SlikkerButton>
    with TickerProviderStateMixin {
  late AnimationController disabledCtrl, hoverCtrl, minorCtrl;
  late CurvedAnimation disabledAnmt, hoverAnmt, minorAnmt;

  @override
  void initState() {
    super.initState();

    AnimationController _basicController(double value) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        value: value,
      );
    }

    CurvedAnimation _basicAnimation(Animation<double> controller) {
      return CurvedAnimation(
        curve: SlikkerOutCurve(),
        parent: controller,
        reverseCurve: SlikkerInCurve(),
      );
    }

    disabledCtrl = _basicController(widget.disabled ? 1 : 0);
    hoverCtrl = _basicController(0);
    minorCtrl = _basicController(widget.disabled ? 1 : 0);

    disabledAnmt = _basicAnimation(disabledCtrl);
    hoverAnmt = _basicAnimation(hoverCtrl);
    minorAnmt = _basicAnimation(minorCtrl);
  }

  @override
  void dispose() {
    disabledCtrl.dispose();
    hoverCtrl.dispose();
    minorCtrl.dispose();
    super.dispose();
  }

  /// Helps to interpolate colors, offsets, shadows based on button's state
  HSVColor _composer({
    required HSVColor enabled,
    HSVColor? minor,
    HSVColor? hover,
    HSVColor? disabled,
  }) {
    HSVColor result = enabled;

    if (minor != null) result = HSVColor.lerp(result, minor, minorAnmt.value)!;
    if (hover != null) result = HSVColor.lerp(result, hover, hoverAnmt.value)!;
    if (disabled != null)
      disabled = HSVColor.lerp(result, disabled, disabledAnmt.value)!;

    return result;
  }

  Widget buildButton(context, child) {
    Widget button = child;

    if (widget.padding != null)
      button = Padding(padding: widget.padding!, child: button);

    button = buildTapable(
      child: button,
      borderRadius: BorderRadius.zero,
      splashColor: Colors.white,
      splashFactory: SlikkerRipple(),
      onHover: (hovered) {
        if (hovered) {
          hoverAnmt.curve = SlikkerOutCurve();
          hoverCtrl.forward(from: 0);
        } else {
          hoverAnmt.curve = SlikkerInCurve();
          hoverCtrl.reverse(from: 1);
        }
      },
      onTapDown: (a) {
        if (!widget.disabled) {
          HapticFeedback.lightImpact();
          minorCtrl.reverse();
        }
      },
      onTapCancel: () {
        if (!widget.disabled && !widget.minor) {
          minorCtrl.reverse();
        }
      },
      onTap: () {
        if (!widget.disabled && !widget.minor) {
          Future.delayed(
            Duration(milliseconds: 250),
            () => minorCtrl.reverse(),
          );
        }
        if (widget.onTap != null) {
          Future.delayed(
            Duration(milliseconds: 100),
            widget.onTap!(),
          );
        }
      },
    );

    button = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.lerp(
            widget.borderRadius, BorderRadius.circular(16), hoverAnmt.value),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _composer(
              enabled: HSVColor.fromAHSV(1, widget.accent, .03, .99),
              hover: HSVColor.fromAHSV(1, widget.accent, .05, .99),
            ).toColor(),
            _composer(
              enabled: HSVColor.fromAHSV(1, widget.accent, .02, .99),
              hover: HSVColor.fromAHSV(1, widget.accent, .04, .99),
            ).toColor(),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: HSVColor.fromAHSV(1, widget.accent, .09, .97).toColor(),
            offset: Offset(0, 4),
            blurRadius: 24,
          ),
        ],
      ),
      child: button,
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        /*..setEntry(3, 2, 0.001) ..rotateX(angle)..rotateY(angle)*/
        ..scale(lerpDouble(1, 1.15, hoverAnmt.value)!),
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        disabledAnmt,
        hoverAnmt,
        minorAnmt,
      ]),
      child: widget.child,
      builder: buildButton,
    );
  }
}

Widget buildTapable({
  required Widget child,
  required BorderRadius borderRadius,
  required Color splashColor,
  required InteractiveInkFeatureFactory splashFactory,
  required Function(TapDownDetails) onTapDown,
  required Function() onTap,
  required Function() onTapCancel,
  required Function(bool) onHover,
}) {
  return Material(
    color: Colors.transparent,
    borderRadius: borderRadius,
    child: InkWell(
      borderRadius: borderRadius,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: SlikkerRipple(),
      splashColor: splashColor,
      onTapDown: onTapDown,
      onTapCancel: onTapCancel,
      onTap: onTap,
      onHover: onHover,
      child: child,
    ),
  );
}

class SlikkerOutCurve extends ElasticOutCurve {
  final double period;

  const SlikkerOutCurve([this.period = 0.6]);

  @override
  double transformInternal(double t) {
    final double s = period / 4.0;
    return math.pow(2.0, -8 * t) *
            math.sin((t - s) * (math.pi * 2.0) / period) +
        1.0;
  }
}

class SlikkerInCurve extends ElasticOutCurve {
  final double period;

  const SlikkerInCurve([this.period = 0.6]);

  @override
  double transformInternal(double t) {
    final double s = period / 4.0;
    t = t - 1.0;
    return -math.pow(2.0, 5.0 * t) *
        math.sin((t - s) * (math.pi * 2.0) / period);
  }
}

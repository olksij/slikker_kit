import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:slikker_kit/slikker_kit.dart';
import 'ripple.dart';

Function lerp = lerpDouble;

class TapPosition {
  final double dx, dy;
  const TapPosition(this.dx, this.dy);
}

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
    Key? key,
    this.accent = 240,
    this.minor = false,
    this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.disabled = false,
    this.padding,
    this.margin,
  }) : super(key: key);
}

class _SlikkerButtonState extends State<SlikkerButton>
    with TickerProviderStateMixin {
  late AnimationController disabledCtrl, hoverCtrl, minorCtrl, pressCtrl;
  late CurvedAnimation disabledAnmt, hoverAnmt, minorAnmt, pressAnmt;
  late GlobalKey _key;

  TapPosition tapPosition = TapPosition(0, 0);

  @override
  void initState() {
    super.initState();
    _key = GlobalKey();

    // Initialize animation controllers.
    disabledCtrl = _basicController(widget.disabled ? 1 : 0);
    hoverCtrl = _basicController(0);
    minorCtrl = _basicController(widget.minor ? 1 : 0);
    pressCtrl = _basicController(0);

    // Initialize curved animation.
    disabledAnmt = _basicAnimation(disabledCtrl);
    hoverAnmt = _basicAnimation(hoverCtrl);
    minorAnmt = _basicAnimation(minorCtrl);
    pressAnmt = _basicAnimation(pressCtrl);
  }

  // Generic controller required.
  AnimationController _basicController(double value) {
    return AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      value: value,
    );
  }

  // Generic curve animation required.
  CurvedAnimation _basicAnimation(Animation<double> controller) {
    return CurvedAnimation(
      curve: SlikkerOutCurve(),
      parent: controller,
      reverseCurve: SlikkerInCurve(),
    );
  }

  @override
  void dispose() {
    disabledCtrl.dispose();
    hoverCtrl.dispose();
    minorCtrl.dispose();
    super.dispose();
  }

  void hover(bool state) {
    if (widget.disabled) return;
    hoverAnmt.curve = state ? SlikkerOutCurve() : SlikkerInCurve();
    if (state)
      hoverCtrl.forward(from: 0);
    else
      hoverCtrl.reverse(from: 1);
  }

  void press(bool state, [TapDownDetails? details]) {
    if (!widget.disabled) {
      hover(state);
      if (state) HapticFeedback.lightImpact();
    }
    /*final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (details != null && renderBox != null) {
      final Size size = renderBox.size;
      tapPosition = TapPosition(
        details.localPosition.dx / size.width * -2 + 1,
        details.localPosition.dy / size.height * 2 - 1,
      );
      pressAnmt.curve = SlikkerOutCurve();
      pressCtrl.forward(from: 0);
      Future.delayed(Duration(milliseconds: 500), () {
        pressAnmt.curve = SlikkerInCurve();
        pressCtrl.reverse(from: 1);
      });
    }*/
  }

  Widget buildButton(context, child) {
    Widget button = child;

    if (widget.padding != null)
      button = Padding(padding: widget.padding!, child: child);

    button = buildTapable(
      child: button,
      splashColor: Colors.white,
      splashFactory: SlikkerRipple(),
      onHover: (state) => hover(state),
      onTapDown: (details) => press(true, details),
      onTapCancel: () => press(false),
      onTap: () {
        Function? onTap = widget.onTap;
        if (onTap != null) Future.delayed(Duration(milliseconds: 100), onTap());
        Future.delayed(Duration(milliseconds: 200), () => press(false));
      },
    );

    /*button = GestureDetector(child: button,
      //: (state) => hover(state),
      onTapDown: (details) => press(true, details),
      onTapCancel: () => press(false),
      onTap: () {
        Function? onTap = widget.onTap;
        if (onTap != null) Future.delayed(Duration(milliseconds: 100), onTap());
        Future.delayed(Duration(milliseconds: 200), () => press(false));
      },
    );*/

    /*button = CustomPaint(
      child: button,
      painter: SlikkerRipple(),
    );*/

    button = Container(
      key: _key,
      clipBehavior: Clip.hardEdge,
      child: button,
      decoration: BoxDecoration(
        /*borderRadius: BorderRadius.lerp(
          widget.borderRadius,
          BorderRadius.circular(16),
          hoverAnmt.value,
        ),*/
        borderRadius: widget.borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSVColor.fromAHSV(1, widget.accent, .02, .99)
                .withAlpha(lerp(.9, .75, hoverAnmt.value) ?? 1)
                .toColor(),
            HSVColor.fromAHSV(1, widget.accent, .03, .99)
                .withAlpha(lerp(.9, .75, hoverAnmt.value) ?? 1)
                .toColor(),
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
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        //..setEntry(3, 2, 0.001)
        //..rotateY(lerp(0, tapPosition.dx / 2, pressAnmt.value) ?? 0)
        //..rotateX(lerp(0, tapPosition.dy / 2, pressAnmt.value) ?? 0)
        ..scale(lerp(1, 1.1, hoverAnmt.value)!),
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
  required Color splashColor,
  required InteractiveInkFeatureFactory splashFactory,
  required Function(TapDownDetails) onTapDown,
  required Function() onTap,
  required Function() onTapCancel,
  required Function(bool) onHover,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
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

class _SlikkerRipple extends CustomPainter {
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
  }

  @override
  bool shouldRepaint(_SlikkerRipple oldDelegate) => false;
}

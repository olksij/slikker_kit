import 'dart:ui';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'animations.dart';

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
  final Function onTap;

  static function() {}

  @override
  _SlikkerButtonState createState() => _SlikkerButtonState();

  SlikkerButton({
    Key? key,
    this.accent = 240,
    this.minor = false,
    this.child,
    this.onTap = function,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.disabled = false,
    this.padding,
    this.margin,
  }) : super(key: key);
}

class _SlikkerButtonState extends State<SlikkerButton>
    with TickerProviderStateMixin {
  late SlikkerAnimationController disabledAnmt, hoverAnmt, minorAnmt, pressAnmt;

  TapPosition tapPosition = TapPosition(0, 0);

  @override
  void initState() {
    super.initState();

    // Initialize slikker animation.
    disabledAnmt = _initSlikkerAnimation(widget.disabled);
    minorAnmt = _initSlikkerAnimation(widget.minor);
    hoverAnmt = _initSlikkerAnimation(false);
    pressAnmt = _initSlikkerAnimation(false);
  }

  // Generic slikker animation controller required.
  SlikkerAnimationController _initSlikkerAnimation(bool value) {
    return SlikkerAnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      curve: SlikkerCurve(smthns: 10),
      reverseCurve: SlikkerCurve.reverse(smthns: 6),
      value: value ? 1 : 0,
    );
  }

  @override
  void dispose() {
    disabledAnmt.dispose();
    hoverAnmt.dispose();
    minorAnmt.dispose();
    super.dispose();
  }

  void hover(bool state) {
    if (widget.disabled) return;
    hoverAnmt.run(state);
  }

  void touchEvent({TapDownDetails? tapDown, TapUpDetails? tapUp}) {
    if (widget.disabled) return;

    if (tapDown != null) HapticFeedback.lightImpact();

    pressAnmt.run(tapDown != null);

    tapPosition = TapPosition(
      tapDown?.localPosition.dx ?? tapUp!.localPosition.dx,
      tapDown?.localPosition.dy ?? tapUp!.localPosition.dy,
    );
  }

  Widget _buildButton(context, child) {
    Widget button = child;
    late double elevation;

    if (hoverAnmt.controller.isAnimating || hoverAnmt.value > 0)
      elevation = hoverAnmt.value - pressAnmt.value * hoverAnmt.value * 0.75;
    else
      elevation = (1 - hoverAnmt.value) * pressAnmt.value;

    if (widget.padding != null)
      button = Padding(padding: EdgeInsets.all(15), child: button);

    if (!widget.disabled)
      button = GestureDetector(
        onTapDown: (details) => touchEvent(tapDown: details),
        onTapUp: (details) => touchEvent(tapUp: details),
        onTap: () => widget.onTap(),
        child: MouseRegion(
          onEnter: (event) => hoverAnmt.run(true),
          onExit: (event) => hoverAnmt.run(false),
          child: button,
        ),
      );

    button = CustomPaint(
      painter: _ButtonEffects(
        accent: widget.accent,
        tapPosition: tapPosition,
        pressCtrl: pressAnmt,
        borderRadius: BorderRadius.lerp(
          widget.borderRadius,
          BorderRadius.circular(16),
          elevation,
        )!,
        elevation: elevation,
      ),
      child: button,
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        //..setEntry(3, 2, 0.001)
        //..rotateY(lerp(0, tapPosition.dx / 2, pressAnmt.value) ?? 0)
        //..rotateX(lerp(0, tapPosition.dy / 2, pressAnmt.value) ?? 0)
        ..scale(lerpDouble(1, 1.15, elevation)!),
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        disabledAnmt.animation,
        hoverAnmt.animation,
        minorAnmt.animation,
        pressAnmt.animation,
      ]),
      child: widget.child,
      builder: _buildButton,
    );
  }
}

class _ButtonEffects extends CustomPainter {
  double accent;
  BorderRadius borderRadius;
  TapPosition? tapPosition;
  SlikkerAnimationController pressCtrl;
  double elevation;

  _ButtonEffects({
    required this.accent,
    required this.borderRadius,
    required this.tapPosition,
    required this.pressCtrl,
    required this.elevation,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    canvas = paintBox(canvas: canvas, size: size, borderRadius: borderRadius);
  }

  Canvas paintBox({
    required Canvas canvas,
    required Size size,
    required BorderRadius borderRadius,
  }) {
    final Paint paintLight = Paint()..color = Color(0x22FFFFFF);

    final paintBoxShadow = lerpDouble(.75, .65, elevation) ?? .6;
    final Paint paintBox = Paint()
      ..color = HSVColor.fromAHSV(paintBoxShadow, accent, .02, .99).toColor();

    final paintKeyShadow = Paint()
      ..color = HSVColor.fromAHSV(.25, accent, .05, .95).toColor();

    final paintAmbientShadow = Paint()
      ..color = HSVColor.fromAHSV(.5, accent, .1, .97).toColor()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16);

    final double topBorder = max(
      borderRadius.topLeft.y,
      borderRadius.topRight.y,
    );

    final double bottomBorder = max(
      borderRadius.bottomLeft.y,
      borderRadius.bottomRight.y,
    );

    RRect boxBase(double top, double height, bool light, [bool all = false]) {
      return RRect.fromRectAndCorners(
        Rect.fromLTWH(0, top, size.width, height),
        topLeft: light || all ? borderRadius.topLeft : Radius.zero,
        topRight: light || all ? borderRadius.topRight : Radius.zero,
        bottomLeft: !light || all ? borderRadius.bottomLeft : Radius.zero,
        bottomRight: !light || all ? borderRadius.bottomRight : Radius.zero,
      );
    }

    final lightPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(boxBase(0, topBorder, true)),
      Path()..addRRect(boxBase(2, topBorder, true)),
    );

    final _heightDelta = size.height - bottomBorder;
    final keyShadowPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(boxBase(_heightDelta + 3, bottomBorder, false)),
      Path()..addRRect(boxBase(_heightDelta, bottomBorder, false)),
    );

    return canvas
      ..drawRRect(boxBase(4, size.height, true, true), paintAmbientShadow)
      ..drawPath(keyShadowPath, paintKeyShadow)
      ..drawRRect(boxBase(0, size.height, true, true), paintBox)
      ..drawPath(lightPath, paintLight);
  }

  @override
  bool shouldRepaint(_ButtonEffects oldDelegate) => false;
}

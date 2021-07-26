import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'animations.dart';

// TODO: Implement disabled state.
// TODO: Implement minor state.
// TODO: Rename to material.
// TODO: Dark theme.

const Duration _lightFadeInDuration = Duration(milliseconds: 200);
const Duration _lightFadeOutDuration = Duration(milliseconds: 500);
const Duration _lightPressDuration = Duration(milliseconds: 1000);
const Duration _lightRadiusDuration = Duration(milliseconds: 500);

class SlikkerButton extends StatefulWidget {
  SlikkerButton({
    Key? key,
    this.accent = 240,
    this.minor = false,
    this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.disabled = false,
    this.padding,
  }) : super(key: key);

  @override
  _SlikkerButtonState createState() => _SlikkerButtonState();

  /// The Hue which will be used for your button. Expected value from 0.0 to 360.0
  final double accent;

  /// If [minor] is true, element lowers by z axis, becoming less noticable.
  ///
  /// Can be used to hint user for another suggested action.
  final bool minor;

  /// Whether the button is enabled or disabled.
  final bool disabled;

  /// If non-null, the corners of this box are rounded by this [BorderRadiusGeometry] value.
  final BorderRadius? borderRadius;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// The empty space that surrounds the card inside.
  final EdgeInsetsGeometry? padding;

  /// The [Function] that will be invoked on user's tap.
  final Function? onTap;
}

class _SlikkerButtonState extends State<SlikkerButton>
    with TickerProviderStateMixin {
  /// Represents state of the button.
  late final SlikkerAnimationController disabled, hover, minor, press;
  late final SlikkerAnimationController lightFade, lightRadius;

  /// Keeps the position where user have tapped.
  Offset tapPosition = Offset(0, 0);

  @override
  void initState() {
    super.initState();

    // Initialize slikker animation.
    disabled = _initSlikkerAnimation(value: widget.disabled);
    minor = _initSlikkerAnimation(value: widget.minor);
    hover = _initSlikkerAnimation();
    press = _initSlikkerAnimation();
    lightFade = _initSlikkerAnimation(
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    lightRadius = _initSlikkerAnimation(
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut,
    );
  }

  /// Generic slikker animation controller required.
  SlikkerAnimationController _initSlikkerAnimation({
    bool value = false,
    Curve? curve,
    Curve? reverseCurve,
  }) {
    return SlikkerAnimationController(
      duration: Duration(milliseconds: 600),
      curve: curve ?? SlikkerCurve(smthns: 10),
      reverseCurve: reverseCurve ?? SlikkerCurve.reverse(smthns: 6),
      vsync: this,
    );
  }

  @override
  void dispose() {
    disabled.dispose();
    hover.dispose();
    minor.dispose();
    press.dispose();
    lightFade.dispose();
    lightRadius.dispose();
    super.dispose();
  }

  /// Number ranging from 0.0 to 1.0, where 1.0 means that element is elevated.
  /// Elevation represents button's state.
  double get elevation => lerpDouble((1 - hover.value) * press.value,
      hover.value - press.value * hover.value * 0.75, hover.value)!;

  /// Button's [BorderRadius] based on [elevation].
  BorderRadius get borderRadius => BorderRadius.lerp(
      widget.borderRadius, BorderRadius.circular(16), elevation)!;

  // Fired when user touch or press on button
  void _touchEvent({TapDownDetails? tapDown, TapUpDetails? tapUp}) {
    if (widget.disabled) return;

    if (tapDown != null) {
      // Tap down event.
      HapticFeedback.lightImpact();

      // Save current tap position.
      tapPosition = Offset(
        tapDown.localPosition.dx,
        tapDown.localPosition.dy,
      );

      // Run animations.
      press.run(true);
      lightFade.run(true, duration: _lightFadeInDuration);
      lightRadius.run(true, duration: _lightRadiusDuration);
    } else {
      // Tap up event.
      press.run(false);
      //lightRadius.duration = _lightRadiusDuration;
      lightFade.run(false, duration: _lightFadeOutDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: widget.child,
      builder: (context, child) {
        // Give button padding if available
        Widget button = Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: child,
        );

        // Add gesture listeners if not disabled
        if (!widget.disabled && widget.onTap != null)
          button = GestureDetector(
            onTapDown: (details) => _touchEvent(tapDown: details),
            onTapUp: (details) => _touchEvent(tapUp: details),
            onTapCancel: () => _touchEvent(),
            onTap: () => widget.onTap!(),
            child: MouseRegion(
              onEnter: (event) => hover.run(true),
              onExit: (event) => hover.run(false),
              child: button,
            ),
          );

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(1 + .15 * elevation),
          child: CustomPaint(
            painter: _ButtonEffects(this),
            child: button,
          ),
        );
      },
      animation: Listenable.merge([
        disabled.listenable,
        hover.listenable,
        minor.listenable,
        press.listenable,
        lightFade.listenable,
        lightRadius.listenable,
      ]),
    );
  }
}

class _ButtonEffects extends CustomPainter {
  _SlikkerButtonState button;

  _ButtonEffects(this.button) : super();

  @override
  void paint(Canvas canvas, Size size) {
    canvas = paintBox(canvas, size);
    canvas = paintRipple(canvas, size);
  }

  /// Paints shadows, light paths, and button itself.
  Canvas paintBox(Canvas canvas, Size size) {
    // Extract variables.
    double accent = button.widget.accent;
    BorderRadius borderRadius = button.borderRadius;

    // Initializing Paint objects.

    final paintLight = Paint()..color = Color(0x33FFFFFF);

    final paintBoxA = lerpDouble(.75, .65, button.elevation)!;
    final paintBox = Paint()
      ..color = HSVColor.fromAHSV(paintBoxA, accent, .02, .99).toColor();

    final paintKeyShadow = Paint()
      ..color = HSVColor.fromAHSV(.25, accent, .05, .95).toColor();

    final paintAmbientShadow = Paint()
      ..color = HSVColor.fromAHSV(.5, accent, .1, .97).toColor()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16);

    // Top borders

    final double topBorder = max(
      borderRadius.topLeft.y,
      borderRadius.topRight.y,
    );

    final double bottomBorder = max(
      borderRadius.bottomLeft.y,
      borderRadius.bottomRight.y,
    );

    // Box Base

    RRect boxBase(double top, double height, bool light, [bool all = false]) {
      return RRect.fromRectAndCorners(
        Rect.fromLTWH(0, top, size.width, height),
        topLeft: light || all ? borderRadius.topLeft : Radius.zero,
        topRight: light || all ? borderRadius.topRight : Radius.zero,
        bottomLeft: !light || all ? borderRadius.bottomLeft : Radius.zero,
        bottomRight: !light || all ? borderRadius.bottomRight : Radius.zero,
      );
    }

    // Generate required paths

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

    // Draw into canvas

    return canvas
      ..drawRRect(boxBase(4, size.height, true, true), paintAmbientShadow)
      ..drawPath(keyShadowPath, paintKeyShadow)
      ..drawRRect(boxBase(0, size.height, true, true), paintBox)
      ..drawPath(lightPath, paintLight);
  }

  Canvas paintRipple(Canvas canvas, Size size) {
    // Extract variables.
    BorderRadius borderRadius = button.borderRadius;
    Offset tapPosition = button.tapPosition;
    int fade = button.lightFade.value * 255 ~/ 1.5;
    double radius = button.lightRadius.value *
        sqrt(pow(size.width, 2) + pow(size.height, 2));

    final colors = [
      Color(0xFFFFFF).withAlpha(fade ~/ 1.5),
      Color(0xFFFFFF).withAlpha(fade),
    ];

    final paintRipple = Paint()
      ..shader = RadialGradient(colors: colors).createShader(Rect.fromCircle(
        radius: radius,
        center: tapPosition,
      ));

    // Clip canvas, so ripple doesnt overflow.
    canvas.clipRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    ));

    final rect = Rect.fromCircle(center: tapPosition, radius: radius);

    return canvas..drawOval(rect, paintRipple);
  }

  @override
  bool shouldRepaint(_ButtonEffects oldDelegate) => true;
}

import 'dart:ui';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:slikker_kit/slikker_kit.dart';

import 'animations.dart';

// TODO: Implement disabled state.

// TODO: Implement minor state.

const Duration _lightFadeInDuration = Duration(milliseconds: 200);
const Duration _lightFadeOutDuration = Duration(milliseconds: 500);
const Duration _lightPressDuration = Duration(milliseconds: 1000);
const Duration _lightRadiusDuration = Duration(milliseconds: 500);

class SlikkerMaterial extends StatefulWidget {
  SlikkerMaterial({
    Key? key,
    this.minor = false,
    this.child,
    this.onTap,
    this.borderRadius,
    this.disabled = false,
    this.padding,
    this.shape,
  }) : super(key: key);

  @override
  _SlikkerMaterialState createState() => _SlikkerMaterialState();

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

  final BoxShape? shape;
}

class _SlikkerMaterialState extends State<SlikkerMaterial>
    with TickerProviderStateMixin {
  /// Represents state of the button.
  late final SlikkerAnimationController disabled, hover, minor, press;
  late final SlikkerAnimationController lightFade, lightRadius;

  late SlikkerThemeData theme;

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
  double get elevation => hover.value - press.value * 1.5;

  /// Material's [BorderRadius] based on [elevation].
  BorderRadius get borderRadius => BorderRadius.lerp(
      widget.borderRadius ?? theme.borderRadius,
      BorderRadius.circular(20),
      elevation)!;

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
        theme = SlikkerTheme.of(context);

        // Give button padding if available
        Widget button = Transform.scale(
          scale: 1 + elevation * .05,
          alignment: Alignment.center,
          child: Padding(
            padding: widget.padding ?? theme.padding,
            child: child,
          ),
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
              cursor: SystemMouseCursors.click,
              child: button,
            ),
          );

        return Transform.scale(
          scale: 1 + elevation * .05,
          alignment: Alignment.center,
          child: CustomPaint(
            painter: _MaterialEffects(this),
            child: button,
          ),
        );
      },
      animation: Listenable.merge([
        disabled.listenable,
        hover.listenable,
        minor.listenable,
        press.listenable,
      ]),
    );
  }
}

class _MaterialEffects extends CustomPainter {
  _SlikkerMaterialState material;

  _MaterialEffects(this.material) : super();

  @override
  void paint(Canvas canvas, Size size) {
    canvas = paintBox(canvas, size);
    canvas = paintRipple(canvas, size);
  }

  BorderRadius materialBorderRadius(Size size) {
    final circle = material.widget.shape == BoxShape.circle;

    final base = circle
        ? BorderRadius.circular(size.shortestSide / 2)
        : material.widget.borderRadius ?? material.theme.borderRadius;

    final sum =
        base.bottomRight + base.bottomLeft + base.bottomRight + base.bottomLeft;

    final elevated = BorderRadius.all(sum * .64 / 4);

    final demoted = BorderRadius.all(sum / .64 / 4);

    final elevationResult =
        BorderRadius.lerp(base, elevated, material.hover.value);

    return BorderRadius.lerp(elevationResult, demoted, material.press.value)!;
  }

  /// Paints shadows, light paths, and material itself.
  Canvas paintBox(Canvas canvas, Size size) {
    // Extract variables.
    final double accent = material.theme.accent;
    final BorderRadius borderRadius = materialBorderRadius(size);

    // Initializing Paint objects.

    final Paint paintLight = Paint()..color = Color(0x33FFFFFF);

    final double paintBoxAlpha = lerpDouble(.7, .6, material.depth)!;
    final Paint paintBox = Paint()
      ..color = HSVColor.fromAHSV(paintBoxAlpha, accent, .02, .99).toColor();

    final Paint paintKeyShadow = Paint()
      ..color = HSVColor.fromAHSV(.2, accent, .05, .95).toColor();

    final Paint paintAmbientShadow = Paint()
      ..color = HSVColor.fromAHSV(.5, accent, .1, .97).toColor()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16);

    final double bottomBorder = max(
      borderRadius.bottomLeft.y,
      borderRadius.bottomRight.y,
    );

    // Box Base

    RRect boxBase(double top, double height, [int wd = 0]) {
      final rect = Rect.fromLTWH(-wd / 2, top, size.width + wd, height);
      return borderRadius.toRRect(rect);
    }

    // Generate required paths

    final lightPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(boxBase(0, size.height)),
      Path()..addRRect(boxBase(2, size.height, 2)),
    );

    final heightDelta = size.height - bottomBorder;
    final keyShadowPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(boxBase(heightDelta + 3, bottomBorder)),
      Path()..addRRect(boxBase(heightDelta, bottomBorder)),
    );

    // Draw into canvas

    return canvas
      ..drawRRect(boxBase(4, size.height), paintAmbientShadow)
      ..drawPath(keyShadowPath, paintKeyShadow)
      ..drawRRect(boxBase(0, size.height), paintBox)
      ..drawPath(lightPath, paintLight);
  }

  Canvas paintRipple(Canvas canvas, Size size) {
    // Extract variables.
    final BorderRadius borderRadius = materialBorderRadius(size);
    final Offset tapPosition = material.tapPosition;
    final int fade = material.lightFade.value * 255 ~/ 2;
    final double radius = material.lightRadius.value *
        sqrt(pow(size.width, 2) + pow(size.height, 2));

    final List<Color> colors = [
      Color(0xFFFFFF).withAlpha(fade ~/ 1.5),
      Color(0xFFFFFF).withAlpha(fade),
    ];

    final rect = Rect.fromCircle(center: tapPosition, radius: radius);

    final Paint paintRipple = Paint()
      ..shader = RadialGradient(colors: colors).createShader(rect);

    // Clip canvas, so ripple doesnt overflow.
    canvas.clipRRect(borderRadius.toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    ));

    return canvas..drawOval(rect, paintRipple);
  }

  @override
  bool shouldRepaint(_MaterialEffects old) =>
      old.material.lightFade != material.lightFade ||
      old.material.lightRadius != material.lightRadius;
}

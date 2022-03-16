import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'animations.dart';
import 'theme.dart';

// TODO: Implement disabled state.

// TODO: Implement minor state.

//const Duration _lightFadeInDuration = Duration(milliseconds: 200);
//const Duration _lightFadeOutDuration = Duration(milliseconds: 500);
//const Duration _lightPressDuration = Duration(milliseconds: 1000);
//const Duration _lightRadiusDuration = Duration(milliseconds: 500);

/// Define [SlikkerMaterial] style.
/// - [elevated] value elevates material by changing to a brighter color,
///   adding light and shadow. High emphasis.
/// - [filled] value fills the material, crreating medium emphasis.
/// - [flat] value makes material transperent, just showing inner content in rest state.
enum MaterialStyle {
  /// Elevates material by changing to a brighter color,
  /// adding light and shadow. High emphasis.
  elevated,

  /// Fills the material, crreating medium emphasis.
  filled,

  /// Makes material transperent, just showing inner content in rest state.
  flat,
}

/// A piece of material.
/// Used to create widgets, which user can interact with.
class SlikkerMaterial extends StatefulWidget {
  /// A piece of material.
  /// Used to create widgets, which user can interact with.
  const SlikkerMaterial({
    Key? key,
    this.minor = false,
    this.child,
    this.onTap,
    this.borderRadius,
    this.disabled = false,
    this.padding,
    this.shape,
    this.style,
    this.height,
    this.width,
    this.onMouseEnter,
    this.onMouseExit,
  }) : super(key: key);

  @override
  _SlikkerMaterialState createState() => _SlikkerMaterialState();

  /// If [minor] is true, element lowers by z axis, becoming less noticable.
  ///
  /// Can be used to hint user for another suggested action.
  final bool minor;

  /// Whether the material is enabled or disabled.
  final bool disabled;

  /// If non-null, the corners of this box are rounded by this [BorderRadiusGeometry] value.
  final BorderRadius? borderRadius;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// The empty space that surrounds the card inside.
  final EdgeInsetsGeometry? padding;

  /// The [Function] that will be invoked on user's tap.
  final Function? onTap;

  /// Triggered when a mouse pointer has entered this widget.
  final Function? onMouseEnter;

  /// Triggered when a mouse pointer has exited this widget when the widget is still mounted.
  final Function? onMouseExit;

  /// Defines the material's shape.
  final BoxShape? shape;

  // Define [SlikkerMaterial] style.
  final MaterialStyle? style;

  final double? height;

  final double? width;
}

class _SlikkerMaterialState extends State<SlikkerMaterial>
    with TickerProviderStateMixin {
  /// Represents state of the material.
  late final SlikkerAnimationController disabled, hover, minor, press;
  late final SlikkerAnimationController lightFade, lightRadius;

  final _key = GlobalKey();

  late SlikkerThemeData theme;

  /// Keeps the position where user have tapped.
  Offset tapPosition = const Offset(0, 0);

  double? factor;

  @override
  void initState() {
    super.initState();
    // Initialize slikker animation.
    disabled = _initAnimation(widget.disabled);
    minor = _initAnimation(widget.minor);
    lightFade = _initAnimation();
    lightRadius = _initAnimation();
    hover = _initAnimation();
    press = _initAnimation();
  }

  /// Generic slikker animation controller required.
  SlikkerAnimationController _initAnimation([bool value = false]) {
    return SlikkerAnimationController(vsync: this, value: value ? 1 : -1);
  }

  @override
  void dispose() {
    for (var anim in [disabled, hover, minor, press, lightFade, lightRadius]) {
      anim.dispose();
    }
    super.dispose();
  }

  /// Number ranging from -1/1.6 to 1.0, where 1.0 means that element is
  /// demoted (pressed or clicked).
  ///
  /// Depth represents material's state.
  double get depth => press.value - hover.value / 1.6;

  /// Calculates the strength of the animation of interactions.
  /// Lower value means more sensetive.
  double? calcFactor() {
    final size = context.size;
    if (size != null) return (size.height + size.width) / 2 / 56;
    return null;
  }

  /// Fired when user hover material
  void hoverEvent(bool state) {
    factor = calcFactor();
    if (state && widget.onMouseEnter != null) widget.onMouseEnter!();
    if (!state && widget.onMouseExit != null) widget.onMouseExit!();
    if (!widget.disabled) hover.run(state);
  }

  /// Fired when user touch or press on material
  void touchEvent({TapDownDetails? tapDown, TapUpDetails? tapUp}) async {
    if (widget.disabled) return;

    factor = calcFactor();

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
      lightFade.run(true); // TODO: CUSTOM VELOCITY
      lightRadius.run(true); // TODO: CUSTOM VELOCITY
    } else {
      // Tap up event.
      await Future.delayed(Duration(
          milliseconds:
              (press.duration!.inMilliseconds * 0.1 * (1 - press.visual) * 0.66)
                  .round()));

      press.run(false);
      lightFade.run(false); // TODO: CUSTOM VELOCITY
    }
  }

  @override
  Widget build(BuildContext context) {
    disabled.run(widget.disabled);
    minor.run(widget.minor);

    return AnimatedBuilder(
      key: _key,
      child: widget.child,
      builder: (context, child) {
        theme = SlikkerTheme.of(context);

        final factor = this.factor ?? 1;

        // Give material padding if available
        Widget material = Transform.scale(
          scale: 1 - depth * .15 / factor,
          alignment: Alignment.center,
          child: Padding(
            padding: widget.padding ?? theme.padding,
            child: child,
          ),
        );

        // Add gesture listeners if not disabled
        if (!widget.disabled && widget.onTap != null) {
          material = GestureDetector(
            onTapDown: (details) => touchEvent(tapDown: details),
            onTapUp: (details) => touchEvent(tapUp: details),
            onTapCancel: () => touchEvent(),
            onTap: () => widget.onTap!(),
            child: MouseRegion(
              onEnter: (event) => hoverEvent(true),
              onExit: (event) => hoverEvent(false),
              cursor: SystemMouseCursors.click,
              child: material,
            ),
          );
        }

        material = SizedBox(
          child: material,
          height: widget.height,
          width: widget.width,
        );

        return Transform.scale(
          scale: 1 - depth * .1 / factor,
          alignment: Alignment.center,
          child: CustomPaint(
            painter: _MaterialEffects(this),
            child: material,
          ),
        );
      },
      animation: Listenable.merge([hover, press]),
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

    // Get the BorderRadius of the material.
    final base = circle
        ? BorderRadius.circular(size.shortestSide / 2)
        : material.widget.borderRadius ?? material.theme.borderRadius;

    // Sum up borders for calculating avarage later.
    final sum =
        base.bottomRight + base.bottomLeft + base.bottomRight + base.bottomLeft;

    // In elevated state borders are less rounded, so material fill
    // more space and create more emphasis.
    final elevated = BorderRadius.all(sum / 1.25 / 4);

    // In pressed state borders are more rounded,
    // so material appears to be smaller, creating higher contrast between states.
    final demoted = BorderRadius.all(sum * 1.25 / 4);

    // Blend with hover elevating.
    final elevationResult =
        BorderRadius.lerp(base, elevated, material.hover.value);

    // Blend with pressed state.
    return BorderRadius.lerp(elevationResult, demoted, material.press.value)!;
  }

  /// Paints shadows, light paths, and material itself.
  Canvas paintBox(Canvas canvas, Size size) {
    // Extract variables.
    final double accent = material.theme.hue;
    final MaterialStyle style = material.widget.style ?? MaterialStyle.elevated;
    final BorderRadius borderRadius = materialBorderRadius(size);

    // Used for defining material state for each material style.
    final double alphaBlend = min(
        max(style != MaterialStyle.elevated ? material.hover.value : 1, 0), 1);

    // INIT PAINT OBJECTS

    final Paint paintLight = Paint()
      ..color = HSVColor.fromAHSV(.3 * alphaBlend, 0, 0, 1).toColor();

    final Paint paintBorder = Paint()
      ..color = HSVColor.fromAHSV(.15 * alphaBlend, 0, 0, 1).toColor();

    final double boxFillAlpha =
        style == MaterialStyle.filled ? .05 * (1 - alphaBlend) : 0;

    final Paint paintBox = Paint()
      ..color = Color.alphaBlend(
        HSVColor.fromAHSV(boxFillAlpha, accent, .4, .3).toColor(),
        HSVColor.fromAHSV(.65 * alphaBlend, accent, 0, 1).toColor(),
      );

    final Paint paintKeyShadow = Paint()
      ..color = HSVColor.fromAHSV(.02 * alphaBlend, accent, .35, .6).toColor();

    final Paint paintAmbientShadow = Paint()
      ..color = HSVColor.fromAHSV(.1 * alphaBlend, accent, .35, .6).toColor()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final double bottomBorder = max(
      borderRadius.bottomLeft.y,
      borderRadius.bottomRight.y,
    );

    // Box Base

    RRect boxBase(double top, double height, [int wd = 0]) {
      final rect = Rect.fromLTWH(-wd / 2, top, size.width + wd, height);
      return borderRadius.toRRect(rect);
    }

    // PAINT LAYERS

    final lightPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(boxBase(0, size.height)),
      Path()..addRRect(boxBase(2, size.height, 2)),
    );

    final innerBox = borderRadius
        .subtract(BorderRadius.circular(2))
        .resolve(TextDirection.ltr)
        .toRRect(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4));

    final borderPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(boxBase(0, size.height)),
      Path()..addRRect(innerBox),
    );

    final heightDelta = size.height - bottomBorder * 2;
    final keyShadowPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(boxBase(heightDelta + 2, bottomBorder * 2)),
      Path()..addRRect(boxBase(heightDelta, bottomBorder * 2)),
    );

    // DRAW ON CANVAS

    return canvas
      ..drawRRect(boxBase(4, size.height), paintAmbientShadow)
      ..drawPath(keyShadowPath, paintKeyShadow)
      ..drawRRect(boxBase(0, size.height), paintBox)
      ..drawPath(borderPath, paintBorder)
      ..drawPath(lightPath, paintLight);
  }

  Canvas paintRipple(Canvas canvas, Size size) {
    // Temporary disabled
    return canvas;

    // Extract variables.
    final BorderRadius borderRadius = materialBorderRadius(size);
    final Offset tapPosition = material.tapPosition;
    final int fade = material.lightFade.value * 255 ~/ 2;
    final double radius = material.lightRadius.value *
        sqrt(pow(size.width, 2) + pow(size.height, 2));

    final List<Color> colors = [
      const Color(0xFFFFFFFF).withAlpha(fade ~/ 1.5),
      const Color(0xFFFFFFFF).withAlpha(fade),
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
      old.material.lightFade.value != material.lightFade.value ||
      old.material.lightRadius.value != material.lightRadius.value ||
      old.material.minor.value != material.minor.value ||
      old.material.disabled.value != material.disabled.value;
}

class SlikkerMaterialTheme {
  factory SlikkerMaterialTheme({
    SlikkerMaterialTheme? theme,
    double? hue,
  }) {
    theme ??= const SlikkerMaterialTheme.light();

    return SlikkerMaterialTheme.raw(
      hue: hue ?? theme.hue,
    );
  }

  const SlikkerMaterialTheme.light() : hue = 240;

  const SlikkerMaterialTheme.dark() : hue = 240;

  const SlikkerMaterialTheme.raw({
    required this.hue,
  });

  final double hue;
}

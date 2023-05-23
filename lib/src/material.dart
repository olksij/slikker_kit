import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'animations.dart';
import 'gesture_detector.dart';
import 'theme.dart';
import 'math.dart';

// TODO: Implement disabled state.

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

  /// Fills the material, creating medium emphasis.
  filled,

  /// Fills the material, crreating medium emphasis.
  stroked,

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
    this.color,
    this.style,
    this.height,
    this.width,
    this.onMouseEnter,
    this.onMouseExit,
    this.theme,
    this.onMouseHover,
    this.tilt = false,
    this.clipBehavior,
  }) : super(key: key);

  @override
  SlikkerMaterialState createState() => SlikkerMaterialState();

  /// If [minor] is true, element lowers by z axis, becoming less noticable.
  ///
  /// Can be used to hint user for another suggested action.
  final bool minor;

  /// Whether the material is enabled or disabled.
  final bool disabled;

  /// Should the material tilt in response to mouse pointer?
  final bool tilt;

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

  /// Triggered when a mouse pointer has entered this widget.
  final Function? onMouseHover;

  // TODO: Doc
  final Color? color;

  /// Triggered when a mouse pointer has exited this widget when the widget is still mounted.
  final Function? onMouseExit;

  /// Defines the material's shape.
  final BoxShape? shape;

  // Define [SlikkerMaterial] style.
  final MaterialStyle? style;

  final double? height;

  final double? width;

  final SLThemeData? theme;

  final Clip? clipBehavior;
}

class SlikkerMaterialState extends State<SlikkerMaterial>
    with TickerProviderStateMixin {
  /// Represents state of the material.
  late final SlikkerAnimationController disabled, hover, minor, press;
  late final SlikkerAnimationController lightFade, lightRadius;

  final _key = GlobalKey();

  late SLThemeData theme;

  /// Keeps the position where user have tapped.
  Offset tapPosition = const Offset(0, 0);

  double weight = 1;

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

  /// Number ranging from -(1 / 1.6) to 1.0, where 1.0 means that element is
  /// demoted (pressed or clicked).
  ///
  /// Depth represents material's state.
  double get depth => press.value - hover.value / 1.6;

  /// Evaluates in which direction should the surface tilt or elevate.
  Vector tilt = Vector(0, 0, 1);

  /// Calculates the weight of the object using surface area.
  /// Used in scale caltulations.
  double calculateWeight() {
    final size = context.size;
    return size != null ? (size.width * size.height) / 512 : 1;
  }

  /// Calculates the tilt of the object's surface based on the provided position.
  /// The result is returned as a [Vector] object.
  updateTilt(Offset position) {
    // Get the size of the object
    final size = (context.size ?? Size.zero);

    // Calculate the position relative to the center of the object
    final centered = position - size.center(Offset.zero);

    // Calculate the x and y tilt values based on the centered position
    final x = centered.dx / size.width;
    final y = centered.dy / size.height;

    // Update the tilt state using the calculated x and y tilt values
    setState(() => tilt = Vector.z(x, y, 1));
  }

  /// Fired when user hover material
  void hoverEvent(bool? state, PointerEvent event) {
    // calculate the weight of the surface before animating
    weight = calculateWeight();

    // run callbacks
    if (state == true) widget.onMouseEnter?.call();
    if (state == false) widget.onMouseExit?.call();
    if (state == null) widget.onMouseHover?.call();

    // if the material is not disabled make it interactive
    if (!widget.disabled && widget.tilt) updateTilt(event.localPosition);
    if (!widget.disabled && state != null) hover.run(state);
  }

  /// Fired when user touch or press on material
  void touchEvent({TapDownDetails? tapDown, TapUpDetails? tapUp}) async {
    if (widget.disabled) return;

    weight = calculateWeight();

    if (tapDown != null) {
      // Tap down event.
      //HapticFeedback.selectionClick();

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
      animation: Listenable.merge([hover, press]),
      builder: (context, child) {
        theme = widget.theme ?? SLTheme.of(context);

        final elevation = 1 - depth / ((weight + 32) / 2) /* * tilt.z*/;

        // Give material padding if available
        Widget material = Transform.scale(
          scale: elevation,
          alignment: Alignment.center,
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(0),
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
              onEnter: (event) => hoverEvent(true, event),
              onExit: (event) => hoverEvent(false, event),
              onHover: (event) => hoverEvent(null, event),
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

        if (widget.clipBehavior != null) {
          material = ClipPath(
            clipBehavior: widget.clipBehavior!,
            child: material,
          );
        }

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.005)
          ..scale(elevation)
          ..rotateX(tilt.y * depth / 2)
          ..rotateY(-tilt.x * depth / 2);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: CustomPaint(
            painter: _MaterialEffects(this),
            child: material,
          ),
        );
      },
    );
  }
}

class _MaterialEffects extends CustomPainter {
  SlikkerMaterialState material;

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
        : material.widget.borderRadius ?? material.theme.materialTheme.borderRadius;

    // Sum up borders for calculating avarage later.
    final sum = base.bottomRight + base.bottomLeft + base.bottomRight + base.bottomLeft;

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
    final theme = material.theme.materialTheme;
    final style = material.widget.style ?? MaterialStyle.elevated;
    final borderRadius = materialBorderRadius(size);
    final themePaintBox = theme.paintBox;

    // if [theme.paintBox] is not null, use it instead of default.
    if (themePaintBox != null) {
      return themePaintBox(canvas, size, borderRadius, material);
    }

    // Used for defining material state for each material style.
    final double alphaBlend = min(
        max(style != MaterialStyle.elevated && style != MaterialStyle.stroked
                ? material.hover.value : 1, 0), 1);

    // INIT PAINT OBJECTS

    final Paint paintLight = Paint()
      ..color = theme.light.withAlpha(theme.light.alpha * alphaBlend ~/ 1);

    final Paint paintBorder = Paint()
      ..color = theme.border.withAlpha(theme.border.alpha * alphaBlend ~/ 1);

    final double boxFillAlpha =
        style == MaterialStyle.filled ? theme.fill.alpha * (1 - alphaBlend) : 0;

    final Paint paintBox = Paint()
      ..color = material.widget.color ??
          Color.alphaBlend(
            theme.fill.withAlpha(boxFillAlpha ~/ 1),
            theme.elevated.withAlpha(theme.elevated.alpha * alphaBlend ~/ 1),
          );

    final shadowK = (style == MaterialStyle.stroked ? 0 : 1) * alphaBlend;

    final Paint paintKeyShadow = Paint()
      ..color = theme.keyShadow.withAlpha(theme.keyShadow.alpha * shadowK ~/ 1);

    final Paint paintAmbientShadow = Paint()
      ..color = theme.ambientShadow.withAlpha(theme.ambientShadow.alpha * shadowK ~/ 1)
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
        .subtract(BorderRadius.circular(1))
        .resolve(TextDirection.ltr)
        .toRRect(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2));

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

class SLMaterialTheme {
  final BorderRadius borderRadius = BorderRadius.circular(12);
  final Color light = const Color(0x4DFFFFFF);
  final Color border = const Color(0x26FFFFFF);
  final Color elevated = const Color(0xE3FFFFFF);
  final Color fill =const Color(0x0D2E2E4D);
  final Color keyShadow = const Color(0x05636399);
  final Color ambientShadow = const Color(0x1A636399);

  final Canvas Function(Canvas, Size, BorderRadius, SlikkerMaterialState)? paintBox = null;
}

/* _MaterialEffects.paintBox() 2021
  /// Paints shadows, light paths, and material itself.
  Canvas paintBox(Canvas canvas, Size size) {
    // Extract variables.
    final double accent = material.theme.hue;
    final MaterialStyle style = material.widget.style ?? MaterialStyle.elevated;
    final BorderRadius borderRadius = materialBorderRadius(size);

    // Used for defining material state for each material style.
    final double alphaBlend = min(
        max(
            style != MaterialStyle.elevated && style != MaterialStyle.stroked
                ? material.hover.value
                : 1,
            0),
        1);

    // INIT PAINT OBJECTS

    final Paint paintLight = Paint()
      ..color = HSVColor.fromAHSV(.3 * alphaBlend, 0, 0, 1).toColor();

    final Paint paintBorder = Paint()
      ..color = style == MaterialStyle.stroked
          ? HSVColor.fromAHSV(.10 * alphaBlend, 0, 0, 0).toColor()
          : HSVColor.fromAHSV(.15 * alphaBlend, 0, 0, 1).toColor();

    final double boxFillAlpha =
        style == MaterialStyle.filled ? .05 * (1 - alphaBlend) : 0;

    final Paint paintBox = Paint()
      ..color = material.widget.color ??
          Color.alphaBlend(
            HSVColor.fromAHSV(boxFillAlpha, accent, .4, .3).toColor(),
            HSVColor.fromAHSV(alphaBlend * 0.9, accent, 0, 1).toColor(),
          );

    final shadowK = style == MaterialStyle.stroked ? 0 : 1;

    final Paint paintKeyShadow = Paint()
      ..color = HSVColor.fromAHSV(.02 * shadowK * alphaBlend, accent, .35, .6)
          .toColor();

    final Paint paintAmbientShadow = Paint()
      ..color = HSVColor.fromAHSV(.1 * shadowK * alphaBlend, accent, .35, .6)
          .toColor()
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
        .subtract(BorderRadius.circular(1))
        .resolve(TextDirection.ltr)
        .toRRect(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2));

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
)

*/

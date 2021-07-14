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
  late GlobalKey _key;

  TapPosition tapPosition = TapPosition(0, 0);

  @override
  void initState() {
    super.initState();
    _key = GlobalKey();

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

  void press(bool state, [TapDownDetails? details]) {
    if (widget.disabled) return;
    pressAnmt.run(state);
    if (state) HapticFeedback.lightImpact();

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
        onTapDown: (details) => press(true, details),
        onTapUp: (details) => press(false),
        onTap: () => widget.onTap(),
        child: MouseRegion(
          onEnter: (event) => hoverAnmt.run(true),
          onExit: (event) => hoverAnmt.run(false),
          child: button,
        ),
      );

    button = CustomPaint(
      painter: _ButtonEffects(
        borderRadius: BorderRadius.lerp(
          widget.borderRadius,
          BorderRadius.circular(16),
          elevation,
        )!,
      ),
      child: button,
    );

    button = DecoratedBox(
      key: _key,
      child: button,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.lerp(
          widget.borderRadius,
          BorderRadius.circular(16),
          elevation,
        ),
        color: HSVColor.fromAHSV(1, widget.accent, .02, .99)
            .withAlpha(lerpDouble(.7, .6, elevation) ?? 1)
            .toColor(),
        /*gradient: LinearGradient(
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
        ),*/
        boxShadow: [
          BoxShadow(
            color: HSVColor.fromAHSV(.75, widget.accent, .09, .97).toColor(),
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
  BorderRadius borderRadius;

  _ButtonEffects({required this.borderRadius}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    canvas =
        paintShadow(canvas: canvas, size: size, borderRadius: borderRadius);
    canvas = paintLight(canvas: canvas, size: size, borderRadius: borderRadius);
  }

  Canvas paintLight({
    required Canvas canvas,
    required Size size,
    required BorderRadius borderRadius,
  }) {
    final paint = Paint()..color = Color(0x33FFFFFF);

    final double topBorder = max(
      borderRadius.topLeft.y,
      borderRadius.topRight.y,
    );

    final light = Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width, topBorder),
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
        )),
      Path()
        ..addRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 2, size.width, topBorder),
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
        )),
    );

    return canvas..drawPath(light, paint);
  }

  Canvas paintShadow({
    required Canvas canvas,
    required Size size,
    required BorderRadius borderRadius,
  }) {
    final keyPaint = Paint()
      ..color = Color(0x1100000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

    final double bottomBorder = max(
      borderRadius.bottomLeft.y,
      borderRadius.bottomRight.y,
    );

    final keyShadow = Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0, size.height - bottomBorder, size.width, bottomBorder + 2),
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        )),
      Path()
        ..addRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0, size.height - bottomBorder, size.width, bottomBorder),
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        )),
    );

    return canvas..drawPath(keyShadow, keyPaint);
  }

  @override
  bool shouldRepaint(_ButtonEffects oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'get_color.dart';
import 'ripple.dart';

class SlikkerCard extends StatefulWidget {
  /// The Hue which will be used for your card. Expected value from 0.0 to 360.0
  final double? accent;

  static double defaultAccent = 240;

  /// If [isFloating] is true, card floats like a button. Recomended to leave this.
  final bool? isFloating;

  /// If non-null, the corners of this box are rounded by this [BorderRadiusGeometry] value.
  final BorderRadius? borderRadius;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// The content will be clipped (or not) according to this option.
  final Clip? clipBehavior;

  /// The empty space that surrounds the card outside.
  final EdgeInsetsGeometry? margin;

  /// The empty space that surrounds the card inside.
  final EdgeInsetsGeometry? padding;

  /// The [Function] that will be invoked on user's tap.
  final Function? onTap;

  @override
  _SlikkerCardState createState() => _SlikkerCardState();

  SlikkerCard({
    this.accent,
    this.isFloating,
    this.child,
    this.onTap,
    this.borderRadius,
    this.clipBehavior,
    this.margin,
    this.padding,
  });
}

class _SlikkerCardState extends State<SlikkerCard> with TickerProviderStateMixin {
  late AnimationController tapController;
  late CurvedAnimation tapAnimation;

  late bool isFloating;

  @override
  void initState() {
    super.initState();
    isFloating = widget.isFloating ?? widget.onTap != null;

    tapController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    tapController.value = isFloating ? 0 : 1;

    tapAnimation = CurvedAnimation(curve: Curves.easeOut, parent: tapController);

    //tapAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tapAnimation,
      child: widget.child,
      builder: (context, child) {
        Widget? contents = child;

        if (widget.padding != null)
          contents = Padding(
            padding: widget.padding!,
            child: contents,
          );

        if (widget.onTap != null)
          contents = Material(
            color: Colors.transparent,
            borderRadius: widget.borderRadius,
            child: InkWell(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashFactory: SlikkerRipple(),
              splashColor: getColor(
                a: 0.1,
                h: widget.accent ?? SlikkerCard.defaultAccent,
                s: 0.15,
                v: .9,
              ),
              onTapDown: (a) {
                HapticFeedback.lightImpact();
                if (isFloating) tapController.forward();
              },
              onTapCancel: () {
                if (isFloating) tapController.reverse();
              },
              onTap: () {
                if (isFloating)
                  Future.delayed(
                    Duration(milliseconds: 250),
                    tapController.reverse,
                  );
                Future.delayed(
                  Duration(milliseconds: 100),
                  () => widget.onTap!(),
                );
              },
              child: contents,
            ),
          );

        return Transform.translate(
          //transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(angle)..rotateY(angle),
          offset: Offset(0, tapAnimation.value * 3 - 3),
          child: Container(
            margin: widget.margin,
            clipBehavior: isFloating ? Clip.hardEdge : Clip.none,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              color: getColor(
                a: 1 - 0.5 * tapAnimation.value,
                h: widget.accent ?? SlikkerCard.defaultAccent,
                s: 0.025 * tapAnimation.value,
                v: 1 - 0.05 * tapAnimation.value,
              ),
              boxShadow: [
                BoxShadow(
                  color: getColor(
                    a: 0.1 - 0.1 * tapAnimation.value,
                    h: widget.accent ?? SlikkerCard.defaultAccent,
                    s: 0.6,
                    v: 1,
                  ),
                  offset: Offset(0, 7 + tapAnimation.value * -2),
                  blurRadius: 40 + tapAnimation.value * -10,
                ),
                BoxShadow(
                  color: getColor(
                    a: 1,
                    h: widget.accent ?? SlikkerCard.defaultAccent,
                    s: 0.03,
                    v: 1,
                  ),
                  offset: Offset(0, 3 - 3 * tapAnimation.value),
                  blurRadius: 0,
                ),
              ],
            ),
            child: contents,
          ),
        );
      },
    );
  }
}

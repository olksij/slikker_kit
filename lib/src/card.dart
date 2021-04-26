import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'get_color.dart';
import 'ripple.dart';

class SlikkerCard extends StatefulWidget {
  /// The Hue which will be used for your card.
  final double accent;

  /// If `true` *[DEFAULT]*, your widget gets shadows, pressing-like tap
  /// feedback, and z-axis.
  final bool isFloating;

  /// Decides how curved will be sides of your card. Default is
  /// `BorderRadius.all(Radius.circular(12))`
  final BorderRadiusGeometry borderRadius;

  /// The widget that is placed inside *SlikkerCard* widget
  final Widget child;

  final EdgeInsetsGeometry padding;

  /// The `Function` that will be invoked on user's tap.
  final Function onTap;

  @override
  _SlikkerCardState createState() => _SlikkerCardState();

  static fun() {}

  SlikkerCard({
    required this.accent,
    this.isFloating = true,
    this.child = const Text('hey?'),
    this.padding = const EdgeInsets.all(0),
    this.onTap = fun,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });
}

class _SlikkerCardState extends State<SlikkerCard>
    with TickerProviderStateMixin {
  late AnimationController tapController;
  late CurvedAnimation tapAnimation;

  @override
  void initState() {
    super.initState();
    tapController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );

    tapController.value = widget.isFloating ? 0 : 1;

    tapAnimation =
        CurvedAnimation(curve: Curves.easeOut, parent: tapController);

    tapAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, tapAnimation.value * 3 - 3),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          color: getColor(
            a: 1 - 0.5 * tapAnimation.value,
            h: widget.accent,
            s: 0.025 * tapAnimation.value,
            v: 1 - 0.05 * tapAnimation.value,
          ),
          boxShadow: [
            BoxShadow(
              color: getColor(
                a: 0.1 - 0.1 * tapAnimation.value,
                h: widget.accent,
                s: 0.6,
                v: 1,
              ),
              offset: Offset(0, 7 + tapAnimation.value * -2),
              blurRadius: 40 + tapAnimation.value * -10,
            ),
            BoxShadow(
              color: getColor(
                a: 1,
                h: widget.accent,
                s: 0.03,
                v: 1,
              ),
              offset: Offset(0, 3 - 3 * tapAnimation.value),
              blurRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashFactory: SlikkerRipple(),
            splashColor: getColor(
              a: 0.1,
              h: widget.accent,
              s: 0.15,
              v: .9,
            ),
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTapDown: (a) {
              HapticFeedback.lightImpact();
              if (widget.isFloating) tapController.forward();
            },
            onTapCancel: () {
              if (widget.isFloating) tapController.reverse();
            },
            onTap: () {
              if (widget.isFloating)
                Future.delayed(
                  Duration(milliseconds: 250),
                  tapController.reverse,
                );
              Future.delayed(
                Duration(milliseconds: 100),
                widget.onTap(),
              );
            },
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

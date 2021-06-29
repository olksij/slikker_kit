import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'ripple.dart';

class SlikkerButton extends StatefulWidget {
  /// The Hue which will be used for your button. Expected value from 0.0 to 360.0
  final double? accent;

  static const double defaultAccent = 240;

  /// Elevantes element, makes it more noticable.
  ///
  /// Attention can be used as hint for user about the next action.
  final bool attention;

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

  @override
  _SlikkerButtonState createState() => _SlikkerButtonState();

  SlikkerButton({
    this.accent = defaultAccent,
    this.child,
    this.onTap,
    this.borderRadius,
    this.attention = true,
    this.disabled = false,
    this.padding,
  });
}

class _SlikkerButtonState extends State<SlikkerButton>
    with TickerProviderStateMixin {
  late AnimationController disabledController;
  late AnimationController hoverController;
  late AnimationController attentionController;

  late CurvedAnimation disabledAnimation;
  late CurvedAnimation hoverAnimation;
  late CurvedAnimation attentionAnimation;

  @override
  void initState() {
    super.initState();

    final AnimationController _basicController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    CurvedAnimation _basicAnimation(Animation<double> controller) {
      return CurvedAnimation(
        curve: Curves.elasticOut,
        parent: controller,
      );
    }

    disabledController = _basicController..value = widget.disabled ? 1 : 0;
    hoverController = _basicController..value = 0;
    attentionController = _basicController..value = widget.disabled ? 1 : 0;

    disabledAnimation = _basicAnimation(disabledController);
    hoverAnimation = _basicAnimation(hoverController);
    attentionAnimation = _basicAnimation(attentionController);
  }

  @override
  void dispose() {
    disabledController.dispose();
    hoverController.dispose();
    attentionController.dispose();
    super.dispose();
  }

  T _composer<T>({
    required T disabled,
    required T hover,
    required T attention,
    required T regular,
  }) {
    T? comp(T? first, T? second, CurvedAnimation animation) {
      return Tween(begin: first, end: second).animate(animation).value;
    }

    return comp(
      comp(comp(regular, attention, attentionAnimation), hover, hoverAnimation),
      disabled,
      disabledAnimation,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        disabledAnimation,
        hoverAnimation,
        attentionAnimation,
      ]),
      child: widget.child,
      builder: (context, child) {
        Widget button =
            Padding(padding: widget.padding ?? EdgeInsets.zero, child: child);

        button = Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          child: InkWell(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashFactory: SlikkerRipple(),
            splashColor: HSVColor.fromAHSV(0.1,
                    widget.accent ?? SlikkerButton.defaultAccent, 0.15, 0.9)
                .toColor(),
            onTapDown: (a) {
              if (!widget.disabled) {
                HapticFeedback.lightImpact();
                attentionController.animateTo(0);
              }
            },
            onTapCancel: () {
              if (!widget.disabled && widget.attention)
                attentionController.animateTo(1);
            },
            onTap: () {
              if (!widget.disabled && widget.attention)
                Future.delayed(
                  Duration(milliseconds: 250),
                  () => attentionController.animateTo(1),
                );
              Future.delayed(
                Duration(milliseconds: 100),
                widget.onTap!(),
              );
            },
            onHover: (hovered) => hoverController.animateTo(hovered ? 1 : 0),
            child: button,
          ),
        );

        List<BoxShadow> boxShadows = [
          BoxShadow(
            color: HSVColor.fromAHSV(
                    0.1, widget.accent ?? SlikkerButton.defaultAccent, 0.6, 1)
                .toColor(),
            offset: Offset(0, 7),
            blurRadius: 40,
          ),
        ];

        button = Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            color: HSVColor.fromAHSV(
                    1, widget.accent ?? SlikkerButton.defaultAccent, 0.025, 1)
                .toColor(),
            boxShadow: boxShadows,
          ),
          child: button,
        );

        return Transform.translate(
          //transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(angle)..rotateY(angle),
          offset: Offset(0, -3),
          child: button,
        );
      },
    );
  }
}

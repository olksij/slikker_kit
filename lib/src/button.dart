import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:slikker_kit/slikker_kit.dart';
import 'ripple.dart';

class SlikkerButton extends StatefulWidget {
  /// The Hue which will be used for your button. Expected value from 0.0 to 360.0
  final double accent;

  static const double defaultAccent = 240;

  /// Elevantes element, makes it more noticable.
  ///
  /// Attention can be used as hint for user about the next action.
  final bool attention;

  /// Whether the button is enabled or disabled.
  final bool disabled;

  /// If non-null, the corners of this box are rounded by this [BorderRadiusGeometry] value.
  final BorderRadius? borderRadius;

  static BorderRadius defaultBorderRadius = BorderRadius.circular(12);

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
    this.accent = defaultAccent,
    this.child,
    this.onTap,
    this.borderRadius,
    this.attention = true,
    this.disabled = false,
    this.padding,
    this.margin,
  });
}

class _SlikkerButtonState extends State<SlikkerButton>
    with TickerProviderStateMixin {
  late AnimationController disabledCtrl, hoverCtrl, attentionCtrl;
  late CurvedAnimation disabledAnmt, hoverAnmt, attentionAnmt;

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

    disabledCtrl = _basicController..value = widget.disabled ? 1 : 0;
    hoverCtrl = _basicController..value = 0;
    attentionCtrl = _basicController..value = widget.disabled ? 1 : 0;

    disabledAnmt = _basicAnimation(disabledCtrl);
    hoverAnmt = _basicAnimation(hoverCtrl);
    attentionAnmt = _basicAnimation(attentionCtrl);
  }

  @override
  void dispose() {
    disabledCtrl.dispose();
    hoverCtrl.dispose();
    attentionCtrl.dispose();
    super.dispose();
  }

  /// Helps to interpolate colors, offsets, shadows based on button's state
  T _composer<T>({
    required T disabled,
    required T hover,
    required T attention,
    required T regular,
  }) {
    T composeTwo({T? first, T? second, required CurvedAnimation animation}) =>
        Tween(begin: first, end: second).animate(animation).value;

    return composeTwo(
      first: composeTwo(
        first: composeTwo(
          first: regular,
          second: attention,
          animation: attentionAnmt,
        ),
        second: hover,
        animation: hoverAnmt,
      ),
      second: disabled,
      animation: disabledAnmt,
    );
  }

  Widget buildButton(context, child) {
    Widget button = child;

    if (widget.padding != null)
      button = Padding(padding: widget.padding!, child: button);

    button = buildTapable(
      child: button,
      borderRadius: widget.borderRadius ?? SlikkerButton.defaultBorderRadius,
      splashColor: Colors.white,
      splashFactory: SlikkerRipple(),
      onHover: (hovered) => hoverCtrl.animateTo(hovered ? 1 : 0),
      onTapDown: (a) {
        if (!widget.disabled) {
          HapticFeedback.lightImpact();
          attentionCtrl.animateTo(0);
        }
      },
      onTapCancel: () {
        if (!widget.disabled && widget.attention) {
          attentionCtrl.animateTo(1);
        }
      },
      onTap: () {
        if (!widget.disabled && widget.attention) {
          Future.delayed(
            Duration(milliseconds: 250),
            () => attentionCtrl.animateTo(1),
          );
        }
        if (widget.onTap != null) {
          Future.delayed(
            Duration(milliseconds: 100),
            widget.onTap!(),
          );
        }
      },
    );

    button = Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSVColor.fromAHSV(1, widget.accent, .03, .99).toColor(),
            HSVColor.fromAHSV(1, widget.accent, .02, .99).toColor(),
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
      child: button,
    );

    return Transform.translate(
      //transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(angle)..rotateY(angle),
      offset: Offset(0, -3),
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        disabledAnmt,
        hoverAnmt,
        attentionAnmt,
      ]),
      child: widget.child,
      builder: buildButton,
    );
  }
}

Widget buildTapable({
  required Widget child,
  required BorderRadius borderRadius,
  required Color splashColor,
  required InteractiveInkFeatureFactory splashFactory,
  required Function(TapDownDetails) onTapDown,
  required Function() onTap,
  required Function() onTapCancel,
  required Function(bool) onHover,
}) {
  return Material(
    color: Colors.transparent,
    borderRadius: borderRadius,
    child: InkWell(
      borderRadius: borderRadius,
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

import 'package:flutter/widgets.dart';

import './material.dart';

class SlikkerButton extends StatelessWidget {
  const SlikkerButton({
    Key? key,
    this.borderRadius,
    this.padding,
    this.icon,
    this.child,
    this.disabled = false,
    this.minor = false,
    this.onTap,
    this.mainAxisSize = MainAxisSize.min,
    this.center,
    this.spacing,
    this.shape,
  }) : super(key: key);

  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Widget? icon;
  final Widget? child;
  final bool disabled;
  final bool minor;
  final Function? onTap;
  final MainAxisSize mainAxisSize;
  final bool? center;
  final double? spacing;
  final BoxShape? shape;

  @override
  Widget build(BuildContext context) {
    late Widget result;

    if (icon != null && child != null)
      result = Row(
        mainAxisSize: mainAxisSize,
        children: [icon!, SizedBox(width: spacing ?? 8), child!],
      );
    else
      result = icon ?? child ?? SizedBox();

    if (center == true) result = Center(child: result);

    return SlikkerMaterial(
      borderRadius: borderRadius,
      child: result,
      padding: padding,
      disabled: disabled,
      minor: minor,
      onTap: onTap,
      shape: shape,
    );
  }
}

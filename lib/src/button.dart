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
  }) : super(key: key);

  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Widget? icon;
  final Widget? child;
  final bool disabled;
  final bool minor;
  final Function? onTap;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return SlikkerMaterial(
      borderRadius: borderRadius,
      child: icon != null && child != null
          ? Row(
              mainAxisSize: mainAxisSize,
              children: [icon!, SizedBox(width: 8), child!],
            )
          : icon ?? child ?? SizedBox(),
      padding: padding,
      disabled: disabled,
      minor: minor,
      onTap: onTap,
    );
  }
}

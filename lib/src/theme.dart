import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class SlikkerTheme extends InheritedWidget {
  const SlikkerTheme({
    required Widget child,
    required this.theme,
    Key? key,
  }) : super(key: key, child: child);

  final SlikkerThemeData theme;

  static SlikkerThemeData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SlikkerTheme>();
    assert(result != null, 'No SlikkerTheme found in context');
    return result?.theme ?? SlikkerThemeData();
  }

  @override
  bool updateShouldNotify(SlikkerTheme old) => theme != old.theme;
}

class SlikkerThemeData {
  factory SlikkerThemeData({
    double? accent,
    Color? accentColor,
    Color? backgroundColor,
    Color? fontColor,
    String? fontFamily,
    FontWeight? fontWeight,
    Color? iconBackgroundColor,
    Color? iconColor,
    Color? statusBarColor,
    Color? navigationBarColor,
    double? iconSize,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    accentColor ??= HSVColor.fromAHSV(1, accent ?? 240, .6, 1).toColor();
    accent ??= HSVColor.fromColor(accentColor).hue;
    backgroundColor ??= HSVColor.fromAHSV(1, accent, 0.05, 0.98).toColor();
    fontFamily ??= '';
    fontWeight ??= FontWeight.w600;
    iconColor ??= HSVColor.fromAHSV(1, accent, .22, .56).toColor();
    iconBackgroundColor ??= HSVColor.fromAHSV(1, accent, .1, .89).toColor();
    iconSize ??= 28;
    fontColor ??= HSVColor.fromAHSV(1, accent, .24, .4).toColor();
    statusBarColor ??= HSVColor.fromAHSV(.05, accent, .2, .2).toColor();
    navigationBarColor ??= HSVColor.fromAHSV(1, accent, 0.06, 0.97).toColor();
    padding ??= EdgeInsets.all(16);
    borderRadius ??= BorderRadius.circular(12);

    return SlikkerThemeData.raw(
      accent: accent,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      iconSize: iconSize,
      fontColor: fontColor,
      statusBarColor: statusBarColor,
      navigationBarColor: navigationBarColor,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  const SlikkerThemeData.raw({
    required this.accent,
    required this.accentColor,
    required this.backgroundColor,
    required this.fontFamily,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.iconSize,
    required this.fontColor,
    required this.fontWeight,
    required this.statusBarColor,
    required this.navigationBarColor,
    required this.padding,
    required this.borderRadius,
  });

  /// The Hue which will be used for your button. Expected value from 0.0 to 360.0
  final double accent;

  final Color accentColor;

  final Color backgroundColor;

  final String? fontFamily;

  final Color fontColor;

  final FontWeight? fontWeight;

  final Color iconColor;

  final Color iconBackgroundColor;

  final double iconSize;

  final Color statusBarColor;

  final Color navigationBarColor;

  final EdgeInsets padding;

  final BorderRadius borderRadius;
}

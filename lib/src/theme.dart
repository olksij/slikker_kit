import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

Color _hsvColor(double a, double h, double s, double v) =>
    HSVColor.fromAHSV(a, h, s, v).toColor();

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
  bool updateShouldNotify(SlikkerTheme oldWidget) => theme != oldWidget.theme;
}

class SlikkerThemeData {
  factory SlikkerThemeData({
    SlikkerThemeData? theme,
    double? hue,
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
    theme ??= SlikkerThemeData.light();

    return SlikkerThemeData.raw(
      hue: hue ?? theme.hue,
      accentColor: accentColor ?? theme.accentColor,
      backgroundColor: backgroundColor ?? theme.backgroundColor,
      fontFamily: fontFamily ?? theme.fontFamily,
      fontWeight: fontWeight ?? theme.fontWeight,
      iconColor: iconColor ?? theme.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? theme.iconBackgroundColor,
      iconSize: iconSize ?? theme.iconSize,
      fontColor: fontColor ?? theme.fontColor,
      statusBarColor: statusBarColor ?? theme.statusBarColor,
      navigationBarColor: navigationBarColor ?? theme.navigationBarColor,
      padding: padding ?? theme.padding,
      borderRadius: borderRadius ?? theme.borderRadius,
    );
  }

  SlikkerThemeData.light({this.hue = 240})
      : accentColor = _hsvColor(1, hue, .6, 1),
        backgroundColor = _hsvColor(1, hue, .05, .98),
        fontFamily = '',
        fontWeight = FontWeight.w600,
        iconColor = _hsvColor(1, hue, .22, .56),
        iconBackgroundColor = _hsvColor(1, hue, .1, .89),
        iconSize = 28,
        fontColor = _hsvColor(1, hue, .24, .4),
        statusBarColor = _hsvColor(.05, hue, .2, .2),
        navigationBarColor = _hsvColor(1, hue, .06, .97),
        padding = const EdgeInsets.all(16),
        borderRadius = BorderRadius.circular(12);

  SlikkerThemeData.dark({this.hue = 240})
      : accentColor = _hsvColor(1, hue, .6, 1),
        backgroundColor = _hsvColor(1, hue, .05, .98),
        fontFamily = '',
        fontWeight = FontWeight.w600,
        iconColor = _hsvColor(1, hue, .22, .56),
        iconBackgroundColor = _hsvColor(1, hue, .1, .89),
        iconSize = 28,
        fontColor = _hsvColor(1, hue, .24, .4),
        statusBarColor = _hsvColor(.05, hue, .2, .2),
        navigationBarColor = _hsvColor(1, hue, .06, .97),
        padding = const EdgeInsets.all(16),
        borderRadius = BorderRadius.circular(12);

  const SlikkerThemeData.raw({
    required this.hue,
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
  final double hue;

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

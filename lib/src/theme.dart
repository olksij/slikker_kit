import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:slikker_kit/slikker_kit.dart';

class SLTheme extends InheritedWidget {
  const SLTheme({
    required Widget child,
    required this.theme,
    Key? key,
  }) : super(key: key, child: child);

  final SLThemeData theme;

  static SLThemeData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SLTheme>();
    assert(result != null, 'No SlikkerTheme found in context');
    return result?.theme ?? SLThemeData();
  }

  @override
  bool updateShouldNotify(SLTheme oldWidget) => theme != oldWidget.theme;
}

class SLThemeData {  
  final Color backgroundColor = const Color(0xFFF5F5F5);

  final TextStyle textStyle = const TextStyle();

  final SLMaterialTheme materialTheme = SLMaterialTheme();

  static Color hsv(double a, double h, double s, double v) =>
      HSVColor.fromAHSV(a, h, s, v).toColor();
}

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class SlikkerTheme extends InheritedWidget {
  const SlikkerTheme({
    required Widget child,
    required this.data,
    Key? key,
  }) : super(key: key, child: child);

  final SlikkerThemeData data;

  static SlikkerTheme of(BuildContext context) {
    final SlikkerTheme? result =
        context.dependOnInheritedWidgetOfExactType<SlikkerTheme>();

    assert(result != null, 'No SlikkerTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SlikkerTheme old) => data != old.data;
}

class SlikkerThemeData {
  const SlikkerThemeData({
    this.accent = 240,
    this.fontFamily,
  });

  const SlikkerThemeData.light()
      : this.accent = 240,
        this.fontFamily = null;

  final double accent;

  final String? fontFamily;
}

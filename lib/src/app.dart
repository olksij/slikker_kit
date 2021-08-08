import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import './theme.dart';

class SlikkerApp extends StatefulWidget {
  SlikkerApp({
    Key? key,
    this.initialRoute,
    this.routes = const <String, WidgetBuilder>{},
    this.color = const Color(0xFFFFFFFF),
    this.theme,
    this.title = '',
  }) : super(key: key);

  final SlikkerThemeData? theme;
  final String? initialRoute;
  final Map<String, WidgetBuilder> routes;
  final Color color;
  final String title;

  @override
  _SlikkerAppState createState() => _SlikkerAppState();
}

class _SlikkerAppState extends State<SlikkerApp> {
  @override
  Widget build(BuildContext context) {
    final SlikkerThemeData theme = widget.theme ?? SlikkerThemeData();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: theme.statusBarColor,
      systemNavigationBarColor: theme.navigationBarColor,
    ));

    return SlikkerTheme(
      theme: theme,
      child: WidgetsApp(
        initialRoute: widget.initialRoute,
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
            MaterialPageRoute<T>(settings: settings, builder: builder),
        routes: widget.routes,
        color: widget.color,
        title: widget.title,
        textStyle: TextStyle(
          fontFamily: theme.fontFamily,
          color: theme.fontColor,
          fontWeight: theme.fontWeight,
        ),
      ),
    );
  }
}

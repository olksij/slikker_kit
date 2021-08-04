import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SlikkerApp extends StatefulWidget {
  SlikkerApp({
    Key? key,
    this.initialRoute,
    this.routes = const <String, WidgetBuilder>{},
    this.color = const Color(0xFFFFFFFF),
    this.title = '',
  }) : super(key: key);

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
    return WidgetsApp(
      initialRoute: widget.initialRoute,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          MaterialPageRoute<T>(settings: settings, builder: builder),
      routes: widget.routes,
      color: widget.color,
      title: widget.title,
    );
  }
}

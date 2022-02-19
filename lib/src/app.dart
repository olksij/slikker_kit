import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;

import './theme.dart';
import './nav_bar.dart';

enum AppElems { nav, app }

class SlikkerApp extends StatefulWidget {
  const SlikkerApp({
    Key? key,
    this.initialRoute,
    this.routes = const <String, WidgetBuilder>{},
    this.color,
    this.theme,
    this.title = '',
    this.home,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorKey,
    this.onGenerateInitialRoutes,
    this.navigatorObservers = const [],
  })  : routerDelegate = null,
        super(key: key);

  const SlikkerApp.router({
    Key? key,
    required this.routerDelegate,
    this.color,
    this.theme,
    this.title = '',
  })  : navigatorObservers = const [],
        navigatorKey = null,
        onGenerateRoute = null,
        home = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        routes = const {},
        initialRoute = null,
        super(key: key);

  // TODO: [CODE] describe
  final SlikkerThemeData? theme;

  // TODO: [CODE] describe
  final String? initialRoute;

  // TODO: [CODE] describe
  final Map<String, WidgetBuilder> routes;

  // TODO: [CODE] describe
  final Color? color;

  // TODO: [CODE] describe
  final String title;

  // TODO: [CODE] describe
  final RouterDelegate? routerDelegate;

  // TODO: [CODE] describe
  final Widget? home;

  // TODO: [CODE] describe
  final Route<dynamic>? Function(RouteSettings)? onGenerateRoute;

  // TODO: [CODE] describe
  final Route<dynamic>? Function(RouteSettings)? onUnknownRoute;

  // TODO: [CODE] describe
  final List<NavigatorObserver> navigatorObservers;

  // TODO: [CODE] describe
  final GlobalKey<NavigatorState>? navigatorKey;

  // TODO: [CODE] describe
  final List<Route<dynamic>> Function(String)? onGenerateInitialRoutes;

  @override
  _SlikkerAppState createState() => _SlikkerAppState();
}

class _SlikkerAppState extends State<SlikkerApp> {
  bool get _usesRouter => widget.routerDelegate != null;

  void overlays(SlikkerThemeData theme) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: theme.statusBarColor,
      systemNavigationBarColor: theme.navigationBarColor,
    ));
  }

  Widget buildNavView(BuildContext context, Widget? child) {
    final SlikkerThemeData theme = widget.theme ?? SlikkerThemeData();

    overlays(theme);

    Widget navigation = SlikkerNavBar(
      navigationEntries: [NavigationEntry(route: '', title: 'Yo')],
    );

    // navRelation supposed to control navigation and scroll view

    List<Widget> navLayout = [];

    <AppElems, Widget>{
      AppElems.nav: navigation,
      AppElems.app: child ?? const SizedBox(),
    }.forEach((id, child) => navLayout.add(LayoutId(id: id, child: child)));

    return SlikkerTheme(
      theme: theme,
      child: CustomMultiChildLayout(
        delegate: _NavbarDelegate(),
        children: navLayout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SlikkerThemeData theme = widget.theme ?? SlikkerThemeData();

    final textStyle = TextStyle(
      fontSize: 16,
      fontFamily: theme.fontFamily,
      color: theme.fontColor,
      fontWeight: theme.fontWeight,
    );

    return WidgetsApp(
      builder: (context, child) => buildNavView(context, child),
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      navigatorObservers: widget.navigatorObservers,
      navigatorKey: widget.navigatorKey,
      onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          MaterialPageRoute<T>(settings: settings, builder: builder),
      routes: widget.routes,
      color: widget.color ?? theme.accentColor,
      title: widget.title,
      textStyle: textStyle,
    );
  }
}

class _NavbarDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    bool wideInterface = size.width > 480;

    // LAYOUT NAVIGATION BAR

    BoxConstraints navLayout =
        BoxConstraints.tightFor(height: size.height, width: 80);
    Size navSize = layoutChild(AppElems.nav, navLayout);

    Offset navPosition = Offset(wideInterface ? 0 : 0 - navSize.width, 0);
    positionChild(AppElems.nav, navPosition);

    // LAYOUT APPLICATION VIEW

    Offset appPosition = Offset(wideInterface ? navSize.width : 0, 0);

    BoxConstraints appLayout = BoxConstraints.tightFor(
      height: size.height,
      width: size.width - (wideInterface ? navSize.width : 0),
    );

    layoutChild(AppElems.app, appLayout);
    positionChild(AppElems.app, appPosition);

    return;
  }

  @override
  bool shouldRelayout(oldDelegate) => false;
}

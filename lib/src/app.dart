import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;

import './theme.dart';
import './nav_bar.dart';

/// SlikkerApp consist of navigation, and application content itself, wrapped with router.
enum _AppElems { nav, app }

/// Creates a widget that wraps a number of widgets that are commonly
/// required for an application.
///
/// Most callers will want to use the [home] or [routes] parameters, or both.
/// The [home] parameter is a convenience for the following [routes] map:
///
/// ```dart
/// <String, WidgetBuilder>{ '/': (BuildContext context) => myWidget }
/// ```
///
/// It is possible to specify both [home] and [routes], but only if [routes] does
///  _not_ contain an entry for `'/'`.  Conversely, if [home] is omitted, [routes]
/// _must_ contain an entry for `'/'`.
///
/// The [builder] parameter is designed to provide the ability to wrap the visible
/// content of the app in some other widget. It is recommended that you use [home]
/// rather than [builder] if you intend to only display a single route in your app.
///
/// Copied from [WidgetsApp].
class SlikkerApp extends StatefulWidget {
  /// Creates a widget that wraps a number of widgets that are commonly
  /// required for an application.
  ///
  /// Most callers will want to use the [home] or [routes] parameters, or both.
  /// The [home] parameter is a convenience for the following [routes] map:
  ///
  /// ```dart
  /// <String, WidgetBuilder>{ '/': (BuildContext context) => myWidget }
  /// ```
  ///
  /// It is possible to specify both [home] and [routes], but only if [routes] does
  ///  _not_ contain an entry for `'/'`.  Conversely, if [home] is omitted, [routes]
  /// _must_ contain an entry for `'/'`.
  ///
  /// The [builder] parameter is designed to provide the ability to wrap the visible
  /// content of the app in some other widget. It is recommended that you use [home]
  /// rather than [builder] if you intend to only display a single route in your app.
  ///
  /// Copied from [WidgetsApp].
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

  /// Creates a [SlikkerApp] that uses the [Router] instead of a [Navigator].
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

  /// Default visual properties, like colors fonts and shapes, for this app's
  /// slikker widgets.
  final SlikkerThemeData? theme;

  /// The name of the first route to show, if a [Navigator] is built.
  final String? initialRoute;

  /// The application's top-level routing table.
  final Map<String, WidgetBuilder> routes;

  /// The primary color to use for the application in the operating system
  /// interface.
  final Color? color;

  /// A one-line description used by the device to identify the app for the user.
  final String title;

  /// A delegate that configures a widget, typically a [Navigator], with
  /// parsed result from the [routeInformationParser].
  final RouterDelegate? routerDelegate;

  /// The widget for the default route of the app ([Navigator.defaultRouteName],
  /// which is `/`).
  final Widget? home;

  /// The route generator callback used when the app is navigated to a
  /// named route.
  final Route<dynamic>? Function(RouteSettings)? onGenerateRoute;

  /// Called when [onGenerateRoute] fails to generate a route, except for the
  /// [initialRoute].
  final Route<dynamic>? Function(RouteSettings)? onUnknownRoute;

  /// The list of observers for the [Navigator] created for this app.
  final List<NavigatorObserver> navigatorObservers;

  /// A key to use when building the [Navigator].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The routes generator callback used for generating initial routes if
  /// [initialRoute] is provided.
  final List<Route<dynamic>> Function(String)? onGenerateInitialRoutes;

  @override
  _SlikkerAppState createState() => _SlikkerAppState();
}

class _SlikkerAppState extends State<SlikkerApp> {
  bool get _usesRouter => widget.routerDelegate != null;

  /// Configure system overlays style.
  void overlays(SlikkerThemeData theme) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: theme.statusBarColor,
      systemNavigationBarColor: theme.navigationBarColor,
    ));
  }

  /// Build navigation view
  Widget buildNavView(BuildContext context, Widget? child) {
    final SlikkerThemeData theme = widget.theme ?? SlikkerThemeData();

    overlays(theme);

    Widget navigation = SlikkerNavBar(
      navigationEntries: [
        NavigationEntry(route: '', title: 'Label'),
        NavigationEntry(route: '', title: 'Label'),
        NavigationEntry(route: '', title: 'Label'),
      ],
    );

    // navRelation supposed to control navigation and scroll view

    List<Widget> navLayout = [];

    <_AppElems, Widget>{
      _AppElems.app: child ?? const SizedBox(),
      _AppElems.nav: navigation,
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

/// Delegate, which manages position and layout of app content and navigation view.
class _NavbarDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    bool wideInterface = size.width > 480;

    // LAYOUT NAVIGATION BAR

    BoxConstraints navLayout =
        BoxConstraints.tightFor(height: size.height, width: 80);
    Size navSize = layoutChild(_AppElems.nav, navLayout);

    Offset navPosition = Offset(wideInterface ? 0 : 0 - navSize.width, 0);
    positionChild(_AppElems.nav, navPosition);

    // LAYOUT APPLICATION VIEW

    Offset appPosition = Offset(wideInterface ? navSize.width : 0, 0);

    BoxConstraints appLayout = BoxConstraints.tightFor(
      height: size.height,
      width: size.width - (wideInterface ? navSize.width : 0),
    );

    layoutChild(_AppElems.app, appLayout);
    positionChild(_AppElems.app, appPosition);

    return;
  }

  @override
  bool shouldRelayout(oldDelegate) => false;
}

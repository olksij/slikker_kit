import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations, MaterialLocalizations, MaterialPageRoute;

//import 'package:flutter_acrylic/flutter_acrylic.dart';

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
    this.routes = const [],
    this.color,
    this.theme,
    this.title = '',
    this.home,
    this.onGenerateRoute,
    this.onUnknownRoute,
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
        onGenerateRoute = null,
        home = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        routes = const [],
        initialRoute = null,
        super(key: key);

  /// Default visual properties, like colors fonts and shapes, for this app's
  /// slikker widgets.
  final SlikkerThemeData? theme;

  /// The name of the first route to show, if a [Navigator] is built.
  final String? initialRoute;

  /// The application's top-level routing table.
  ///
  /// When a named route is pushed with [Navigator.pushNamed], the route name is
  /// looked up in this list of [NavigationEntry]'s. If the name is present, the associated
  /// [widgets.WidgetBuilder] is used to construct a [PageRoute] specified by
  /// [pageRouteBuilder] to perform an appropriate transition, including [Hero]
  /// animations, to the new route.
  ///
  /// If the app only has one page, then you can specify it using [home] instead.
  ///
  /// If [home] is specified, then it implies an entry in this table for the
  /// [Navigator.defaultRouteName] route (`/`), and it is an error to
  /// redundantly provide such a route in the [routes] table.
  ///
  /// If a route is requested that is not specified in this table (or by
  /// [home]), then the [onGenerateRoute] callback is called to build the page
  /// instead.
  ///
  /// The [Navigator] is only built if routes are provided (either via [home],
  /// [routes], [onGenerateRoute], or [onUnknownRoute]); if they are not,
  /// [builder] must not be null.
  /// {@endtemplate}
  ///
  /// If the routes map is not empty, the [pageRouteBuilder] property must be set
  /// so that the default route handler will know what kind of [PageRoute]s to
  /// build.
  final List<NavigationEntry> routes;

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

  /// The routes generator callback used for generating initial routes if
  /// [initialRoute] is provided.
  final List<Route<dynamic>> Function(String)? onGenerateInitialRoutes;

  @override
  _SlikkerAppState createState() => _SlikkerAppState();
}

class _SlikkerAppState extends State<SlikkerApp> {
  bool get _usesRouter => widget.routerDelegate != null;

  /// Used for retrieving [BuildContext] of application view, which is
  /// required by [Navigator] when [Navigator.push()] is fired in [NavigationBar].
  late final GlobalKey<NavigatorState> navigatorKey;

  /// Required for keeping [SlikkerNavBar] always up to date
  /// with current [RouteSettings].
  late final GlobalKey<SlikkerNavBarState> navViewKey;

  /// Background shouldn't be filled on desktop apps as it will be transperent.
  late final bool shouldFillBackground;

  @override
  void initState() {
    navigatorKey = GlobalKey();
    navViewKey = GlobalKey();
    shouldFillBackground = overlays(widget.theme ?? SlikkerThemeData());
    super.initState();
  }

  /// Configure system overlays style.
  bool overlays(SlikkerThemeData theme) {
    final bool shouldFillBackground;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: theme.statusBarColor,
      systemNavigationBarColor: theme.navigationBarColor,
    ));

    return true;

    /*switch (theme.platform) {
      case TargetPlatform.windows:
        Window.initialize().then((_) {
          Window.setEffect(effect: WindowEffect.mica, dark: false);
        });
        shouldFillBackground = false;
        break;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        shouldFillBackground = true;
        break;
    }
    return shouldFillBackground;*/
  }

  /// Build navigation view
  Widget buildNavView(BuildContext context, Widget? child) {
    final SlikkerThemeData theme = widget.theme ?? SlikkerThemeData();

    // navRelation supposed to control navigation and scroll view

    List<Widget> navLayout = [];

    <_AppElems, Widget>{
      _AppElems.app: SizedBox(child: child),
      _AppElems.nav: SlikkerNavBar(
        key: navViewKey,
        routes: widget.routes,
        callback: () => navigatorKey.currentContext!,
      ),
    }.forEach((id, child) => navLayout.add(LayoutId(id: id, child: child)));

    Widget result = SlikkerTheme(
      theme: theme,
      child: SafeArea(
        child: CustomMultiChildLayout(
          delegate: _NavbarDelegate(),
          children: navLayout,
        ),
      ),
    );

    // TODO: [DESIGN] Background adaptation
    // TODO: [DESIGN] Hue adaptation
    // TODO: [FIX] HIDE UI LANDING FALSE

    if (shouldFillBackground) {
      result = ColoredBox(
        color: theme.backgroundColor,
        child: result,
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final SlikkerThemeData theme = widget.theme ?? SlikkerThemeData();

    final Map<String, Widget Function(BuildContext)> routes = {};

    for (NavigationEntry entry in widget.routes) {
      routes[entry.route] = entry.builder;
    }

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
      navigatorKey: navigatorKey,
      onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
      localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
      pageRouteBuilder: <T>(route, builder) {
        navViewKey.currentState?.updateRoute(route);
        return MaterialPageRoute<T>(settings: route, builder: builder);
      },
      routes: routes,
      color: widget.color ?? theme.accentColor,
      title: widget.title,
      textStyle: textStyle,
      home: widget.home,
    );
  }
}

/// Delegate, which manages position and layout of app content and navigation view.
class _NavbarDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    // TODO: [FIX]
    bool wideInterface = size.width > 480 && /*!route.hideUI*/ !true;

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

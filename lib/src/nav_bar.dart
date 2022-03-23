import 'package:slikker_kit/slikker_kit.dart';

class NavigationEntry {
  /// Icon, which will be displayed in Navigation View.
  final IconData? icon;

  /// Route title, which will be displayed in Navigation View.
  final String title;

  /// Route name, which is looked up by [Navigator], when [Navigator.pushNamed] method is called.
  final String route;

  /// Function, which builds page. Used to construct a [PageRoute]
  final Widget Function(BuildContext) builder;

  /// When `true`, [SlikkerApp]'s components are hidden on this route.
  ///
  /// By default `false`.
  ///
  /// Useful in cases homepage present all routes to other pages in a focused UI,
  /// or when homepage is a landing, or when page isn't meaned to look as an app.
  final bool hideUI;

  const NavigationEntry(
    this.route,
    this.builder, {
    this.hideUI = false,
    this.icon,
    this.title = 'Route',
  });
}

class SlikkerNavBar extends StatefulWidget {
  const SlikkerNavBar({
    Key? key,
    required this.routes,
    required this.callback,
  }) : super(key: key);

  /// Pass routes from [SlikkerApp] for proper displaying.
  final List<NavigationEntry> routes;

  /// Used for pulling [BuildContext] of app content,
  /// which is under [Navigator] widget,
  /// so [Navigator.push()] can be odne securely.
  final BuildContext Function() callback;

  @override
  SlikkerNavBarState createState() => SlikkerNavBarState();
}

class SlikkerNavBarState extends State<SlikkerNavBar> {
  /// Current [RouteSettings] in [Navigator].
  RouteSettings? route;

  /// Used for keeping [RouteSettings] up to date with [Navigator].
  void updateRoute(RouteSettings route) => setState(() => this.route = route);

  final List<bool?> states = [];

  @override
  Widget build(BuildContext context) {
    final theme = SlikkerTheme.of(context);

    states.length = widget.routes.length;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 12, top: 12),
      clipBehavior: Clip.none,
      itemCount: widget.routes.length,
      itemBuilder: (context, index) {
        /// Retrive [NavigationEntry] object
        final entry = widget.routes[index];

        /// Indicates the current [Navigator] destination
        final active = route?.name == entry.route;

        /// Used to avoid label to be
        final boxed = active || (states[index] ?? false);

        final icon = AnimatedAlign(
          curve: const SlikkerCurve(
            type: CurveType.curveOut,
            smoothness: 10,
            period: 1,
          ),
          duration: const Duration(milliseconds: 700),
          alignment: boxed ? Alignment.center : Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: IconExtended(
              entry.icon ?? SlikkerIcons.settings,
              color: HSVColor.fromColor(theme.iconColor)
                  .withValue(active ? 0.4 : 0.6)
                  .toColor(),
              backgroundColor: HSVColor.fromColor(theme.iconColor)
                  .withValue(active ? 0.6 : .9)
                  .toColor(),
              size: boxed ? 28 : 26,
            ),
          ),
        );

        final label = AnimatedPositioned(
          duration: const Duration(milliseconds: 700),
          curve: const SlikkerCurve(
            type: CurveType.curveOut,
            smoothness: 10,
            period: 1,
          ),
          bottom: active ? -16 : 2,
          child: AnimatedDefaultTextStyle(
            child: Text(entry.title),
            duration: const Duration(milliseconds: 100),
            style: TextStyle(
              color: theme.fontColor.withAlpha(active
                  ? 175
                  : boxed
                      ? 0
                      : 100),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

        return AnimatedPadding(
          duration: const Duration(milliseconds: 1000),
          curve: const SlikkerCurve(
            type: CurveType.curveOut,
            smoothness: 10,
            period: 1,
          ),
          padding: EdgeInsets.only(bottom: active ? 28 : 12),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              label,
              SlikkerMaterial(
                child: icon,
                padding: const EdgeInsets.all(0),
                style: active ? MaterialStyle.filled : MaterialStyle.flat,
                onTap: () =>
                    Navigator.pushNamed(widget.callback(), entry.route),
                onMouseEnter: () => setState(() => states[index] = true),
                onMouseExit: () => setState(() => states[index] = false),
                height: 56,
              ),
            ],
          ),
        );
      },
    );
  }
}

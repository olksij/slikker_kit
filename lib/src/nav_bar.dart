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
        final entry = widget.routes[index];
        final active = route?.name == entry.route;
        final boxed = active || (states[index] ?? false);

        final icon = AnimatedAlign(
          curve: Curves.elasticOut,
          duration: const Duration(milliseconds: 1000),
          alignment: boxed ? Alignment.center : Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: IconExtended(
              entry.icon ?? SlikkerIcons.settings,
              size: boxed ? 28 : 24,
            ),
          ),
        );

        final label = Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            padding: EdgeInsets.only(bottom: boxed ? 0 : 10),
            child: AnimatedDefaultTextStyle(
              child: Text(entry.title),
              duration: const Duration(milliseconds: 100),
              style: TextStyle(
                color: theme.fontColor.withAlpha(boxed ? 0 : 150),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SlikkerMaterial(
            child: Stack(children: [icon, label]),
            padding: const EdgeInsets.all(0),
            style: active ? MaterialStyle.filled : MaterialStyle.flat,
            onTap: () => Navigator.pushNamed(widget.callback(), entry.route),
            onMouseEnter: () => setState(() => states[index] = true),
            onMouseExit: () => setState(() => states[index] = false),
            height: 60,
          ),
        );
      },
    );
  }
}

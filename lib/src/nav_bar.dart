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

  @override
  Widget build(BuildContext context) {
    final theme = SlikkerTheme.of(context);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 12, top: 12),
      clipBehavior: Clip.none,
      itemCount: widget.routes.length,
      itemBuilder: (context, index) {
        final entry = widget.routes[index];

        final icon = Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: IconExtended(entry.icon ?? SlikkerIcons.settings, size: 24),
        );

        final label = Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            entry.title,
            style: const TextStyle(
              fontSize: 12,
              height: 1,
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SlikkerButton(
            child: Column(children: [icon, label]),
            style: route?.name == entry.route
                ? MaterialStyle.filled
                : MaterialStyle.flat,
            padding: const EdgeInsets.all(8),
            onTap: () => Navigator.pushNamed(widget.callback(), entry.route),
          ),
        );
      },
    );
  }
}

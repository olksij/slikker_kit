import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:slikker_kit/slikker_kit.dart';
import 'package:slikker_kit/src/material.dart';

class NavigationEntry {
  // TODO: [CODE] describe
  final IconData? icon;

  // TODO: [CODE] describe
  final String title;

  // TODO: [CODE] describe
  final String route;

  NavigationEntry({
    this.icon,
    this.title = 'Unnamed route',
    required this.route,
  });
}

class SlikkerNavBar extends StatefulWidget {
  const SlikkerNavBar({
    Key? key,
    required this.navigationEntries,
  }) : super(key: key);

  final List<NavigationEntry> navigationEntries;

  // TODO: implement determination of current destination
  final int activeDestination = 0;

  @override
  _SlikkerNavBarState createState() => _SlikkerNavBarState();
}

class _SlikkerNavBarState extends State<SlikkerNavBar> {
  @override
  Widget build(BuildContext context) {
    final theme = SlikkerTheme.of(context);
    return ColoredBox(
      color: theme.backgroundColor,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        clipBehavior: Clip.none,
        itemCount: widget.navigationEntries.length,
        itemBuilder: (context, index) {
          final entry = widget.navigationEntries[index];

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
              style: widget.activeDestination == index
                  ? MaterialStyle.filled
                  : MaterialStyle.flat,
              padding: const EdgeInsets.all(8),
              onTap: () /*=> Navigator.pushNamed(context, entry.route)*/ {},
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:slikker_kit/slikker_kit.dart';

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
        padding: const EdgeInsets.all(8),
        //shrinkWrap: true,
        itemCount: widget.navigationEntries.length,
        itemBuilder: (context, index) {
          final entry = widget.navigationEntries[index];
          Widget body = Column(
            children: [
              Padding(
                padding: EdgeInsets.all(4),
                child: /*Icon(entry.icon)*/ Container(
                  height: 24,
                  width: 24,
                  color: Color(0xFFDDDDDD),
                ),
              ),
              Text(
                entry.title,
                style: TextStyle(fontSize: 12),
              ),
            ],
          );

          return SlikkerButton(
            child: body,
            padding: EdgeInsets.all(8),
            onTap: () /*=> Navigator.pushNamed(context, entry.route)*/ {},
          );
        },
      ),
    );
  }
}

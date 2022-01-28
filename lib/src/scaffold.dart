import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slikker_kit/slikker_kit.dart';

import './theme.dart';
import './top_button.dart';

/// Widget that helps to build a page.
/// Full documentation will be later
class SlikkerScaffold extends StatefulWidget {
  /// Text that is displayed above `header`. Useally is a text which
  /// indicates which page is it. In Material design it wuld be `AppBarTitle`
  final String? title;

  /// Widget that is displayed above `content`. In Material Design it
  /// is usually `AppBar`.
  final Widget? header;

  /// Content of the page. Place there buttons and main information for user.
  final Widget? content;

  /// Widget that is placed in the bottom of the screen, always visible, and
  /// floats above the `content`.
  final Widget? actionButton;

  const SlikkerScaffold({
    Key? key,
    this.title,
    this.header,
    this.content,
    this.actionButton,
  }) : super(key: key);

  @override
  _SlikkerScaffoldState createState() => _SlikkerScaffoldState();
}

class _SlikkerScaffoldState extends State<SlikkerScaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = SlikkerTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 640) {
          Widget navigationBar = SizedBox(
            width: 72,
            child: ListView(
              shrinkWrap: true,
              children: const [
                SlikkerButton(child: Text('woaa')),
                SlikkerButton(child: Text('testtt')),
              ],
            ),
          );

          Widget titleBar = Container(
            color: Color(0xFFDDFFFF),
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('super title'),
                Align(
                  child: widget.header ?? const SizedBox(),
                  alignment: Alignment.center,
                ),
                widget.actionButton ?? const SizedBox(),
              ],
            ),
          );

          Widget app = Row(
            children: [
              navigationBar,
              const ColoredBox(
                color: Color(0xFFFFFFFF),
                child: Text('mm'),
              ),
            ],
          );

          // TODO: wallpaper adaptivity
          return ColoredBox(
            color: theme.backgroundColor,
            child: Column(children: [titleBar, app]),
          );
        } else {
          return const Text('mobile view to be redesigned');
        }
      },
    );
  }
}

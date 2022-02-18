import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:slikker_kit/slikker_kit.dart';

import './theme.dart';

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

    // Declare inner shell widgets, which are placed into scrollable

    // TODO: [WIDGET] implement topButton
    Widget topButton = const Text('topButton');

    const scrollPhysics = BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );

    _PersistentHeaderDelegate headerDelegate = _PersistentHeaderDelegate(
      header: widget.header,
      title: widget.title,
      topButton: topButton,
      actionButton: widget.actionButton,
    );

    // TODO: [DESIGN] implement wallaper adaptation
    return ColoredBox(
      color: theme.backgroundColor,
      child: CustomScrollView(
        physics: scrollPhysics,
        slivers: [
          SliverPersistentHeader(delegate: headerDelegate),
          SliverToBoxAdapter(child: widget.content),
        ],
      ),
    );
  }
}

class _PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  Widget? header;
  String? title;
  Widget? topButton;
  Widget? actionButton;

  _PersistentHeaderDelegate({
    this.header,
    this.title,
    this.topButton,
    this.actionButton,
  });

  /// Bool, which indicates if the reachability depends of element position.
  /// Usually true for touchable devices;
  // TODO: [DESIGN] implement lowReach
  bool lowReach = true;

  /// Percent of the screen size, to which user can comfortably reach.
  double reachArea = 0.7;

  /// One of the variables, on which layout type depends.
  bool wideInterface = true;

  BuildContext? context;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    this.context = context;
    wideInterface = MediaQuery.of(context).size.width > 480;

    List<Widget> children = [];

    // TODO: [WIDGETS] implement adaptive layouts

    if (title != null) {
      TextStyle titleStyle = TextStyle(
        fontSize: lerpDouble(40, 20, shrinkOffset / (maxExtent - minExtent)),
      );

      children.add(AnimatedPositioned(
        left: 20,
        bottom: 20,
        child: Text(
          title!,
          style: titleStyle,
        ),
        // TODO: [DESIGN] kinematics, remove DURATIONS
        duration: const Duration(milliseconds: 300),
      ));
    }

    return Stack(children: children);
  }

  @override
  double get maxExtent {
    if (!lowReach || context == null) return minExtent;
    return (1 - reachArea) * MediaQuery.of(context!).size.height;
  }

  @override
  // TODO: implement toolbar-adaptive minExtent
  double get minExtent => 72;

  @override
  get stretchConfiguration => OverScrollHeaderStretchConfiguration();

  @override
  bool shouldRebuild(oldDelegate) => false;
}

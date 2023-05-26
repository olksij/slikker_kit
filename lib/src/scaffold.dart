import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:slikker_kit/slikker_kit.dart';
import 'package:flutter/material.dart';

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

  /// Widget that helps to build a page.
  /// Full documentation will be later
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

class _SlikkerScaffoldState extends State<SlikkerScaffold>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = SLTheme.of(context);

    // Declare inner shell widgets, which are placed into scrollable

    // TODO: [WIDGET] implement topButton
    final Widget topButton = Text('topButton');

    final scrollController = ScrollController();

    final _PersistentHeaderDelegate headerDelegate = _PersistentHeaderDelegate(
      vsync: this,
      context: () => context,
      header: widget.header,
      controller: scrollController,
      title: widget.title,
      topButton: topButton,
      actionButton: widget.actionButton,
    );

    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPersistentHeader(delegate: headerDelegate, floating: true),
        SliverToBoxAdapter(child: widget.content),
      ],
    );
  }
}

class SlikkerScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class _PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  Widget? header;
  String? title;
  Widget? topButton;
  Widget? actionButton;
  BuildContext Function() context;

  @override
  TickerProvider vsync;

  ScrollController controller;

  _PersistentHeaderDelegate({
    required this.controller,
    required this.context,
    required this.vsync,
    this.header,
    this.title,
    this.topButton,
    this.actionButton,
  });

  bool scrolled = false;

  /// Percent of the screen size, to which user can comfortably reach.
  double reachArea = 0.66;

  /// One of the variables, on which layout type depends.
  bool wideInterface = false;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    wideInterface = MediaQuery.of(context).size.width > 480;

    if (scrolled && controller.offset == 0) {
      scrolled = false;
      controller.jumpTo(maxExtent - minExtent);
    } else if (!scrolled && controller.offset > maxExtent - minExtent) {
      scrolled = true;
      controller.jumpTo(maxExtent - minExtent);
    }

    List<Widget> children = [];

    // TODO: [WIDGETS] implement adaptive layouts

    if (title != null) {
      TextStyle titleStyle = TextStyle(
        fontSize: scrolled ? 24 : 48,
        fontWeight: FontWeight.w700,
        fontFamily: 'Display',
        letterSpacing: -1.92,
        color: Color(0xFF000000),
      );

      children.add(AnimatedPositioned(
        //curve: const SlikkerCurve(type: CurveType.curveOut),
        left: wideInterface ? 20 : null,
        bottom: 20,
        child: AnimatedDefaultTextStyle(
          curve: const SlikkerCurve(type: CurveType.curveOut),
          duration: const Duration(milliseconds: 800),
          child: Text(title!),
          style: titleStyle,
        ),
        duration: const Duration(milliseconds: 800),
      ));
    }

    return Stack(
      alignment: Alignment.center,
      children: children,
    );
  }

  @override
  double get maxExtent {
    if (scrolled) return minExtent;
    return (1 - reachArea) * MediaQuery.of(context()).size.height;
  }

  @override
  // TODO: implement toolbar-adaptive minExtent
  double get minExtent => 72;

  @override
  get stretchConfiguration => OverScrollHeaderStretchConfiguration();

  @override
  bool shouldRebuild(oldDelegate) => false;
}

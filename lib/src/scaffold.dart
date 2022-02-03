import 'package:flutter/services.dart';
import 'package:slikker_kit/slikker_kit.dart';

import './theme.dart';

enum NavComponents { navigation, scrollview }

enum AppBarComponents { actionButton, topButton, title, header }

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

    // appBarRelation supposed to control elements on top of the screen,
    // which are inserted into scrollview
    Map<AppBarComponents, Widget?> appBarRelation = {
      AppBarComponents.actionButton: widget.actionButton,
      AppBarComponents.topButton: topButton,
      AppBarComponents.header: widget.header,
      AppBarComponents.title: Text(widget.title ?? ''),
    };

    List<Widget> appBarLayout = [];

    appBarRelation.forEach((id, child) {
      if (child != null) appBarLayout.add(LayoutId(id: id, child: child));
    });

    // Declare top shell widgets.

    Widget navigation = const ColoredBox(
      color: Color(0xFFFFFFFF),
      child: Text('nav'),
    );

    const scrollPhysics = BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );

    Widget scrollView = CustomScrollView(
      physics: scrollPhysics,
      slivers: [
        SliverPersistentHeader(delegate: _PersistentHeaderDelegate()),
        SliverToBoxAdapter(child: widget.content),
      ],
    );

    // navRelation supposed to control navigation and scroll view
    Map<NavComponents, Widget?> navRelation = {
      NavComponents.navigation: navigation,
      NavComponents.scrollview: scrollView,
    };

    // Wrap widgets with LayoutIds

    List<Widget> navLayout = [];

    navRelation.forEach((id, child) {
      if (child != null) navLayout.add(LayoutId(id: id, child: child));
    });

    // TODO: [DESIGN] implement wallaper adaptation
    return ColoredBox(
      color: theme.backgroundColor,
      child: CustomMultiChildLayout(
        delegate: _NavScaffoldDelegate(),
        children: navLayout,
      ),
    );
  }
}

class _NavScaffoldDelegate extends MultiChildLayoutDelegate {
  Size setChild(Object childId, Offset offset, BoxConstraints constraints) {
    positionChild(childId, offset);
    return layoutChild(childId, constraints);
  }

  @override
  void performLayout(Size size) {
    bool wideInterface = size.width > 480;

    Size navSize = Size.zero;
    Size scrollviewSize = Size.zero;

    // LAYOUT NAVIGATION

    BoxConstraints navConstraints =
        BoxConstraints.tightFor(height: size.height);

    navSize = layoutChild(NavComponents.navigation, navConstraints);

    Offset navOffset = Offset(wideInterface ? 0 : 0 - navSize.width, 0);

    positionChild(NavComponents.navigation, navOffset);

    // LAYOUT SCROLLVIEW

    BoxConstraints scrollviewConstraints = BoxConstraints.tightFor(
        height: size.height,
        width: size.width - (wideInterface ? navSize.width : 0));

    scrollviewSize =
        layoutChild(NavComponents.scrollview, scrollviewConstraints);

    Offset scrollviewOffset = Offset(wideInterface ? navSize.width : 0, 0);

    positionChild(NavComponents.scrollview, scrollviewOffset);

    return;
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

class _PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Bool, which indicates if the reachability depends of element position.
  /// Usually true for touchable devices;
  // TODO: [DESIGN] implement lowReach
  bool lowReach = true;

  /// Percent of the screen size, to which user can comfortably reach.
  double reachArea = 0.7;

  /// One of the variables, on which layout type depends.
  bool wideInterface = true;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    if (context.size != null) wideInterface = context.size!.width > 480;

    // TODO: [WIDGETS] implement adaptive layouts
    return const Center(
      child: Text('woaaaa'),
    );
  }

  @override
  // TODO: implement lowReach
  double get maxExtent => lowReach
      ? minExtent
      : (1 - reachArea) * MediaQuery.of(context).size.height;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

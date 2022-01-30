import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slikker_kit/slikker_kit.dart';

import './theme.dart';
import './top_button.dart';

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

    // Declare shell widgets.

    Widget navigation = const ColoredBox(
      color: Color(0xFFFFFFFF),
      child: Text('nav'),
    );

    // TODO: topButton
    Widget topButton = const Text('topButton');

    // TODO: scrollView
    Widget scrollView = const SizedBox();

    // Building id-widget relations for CustomMultiChildLayout  widgets.

    // topRelation supposed to control navigation and scroll view
    Map<NavComponents, Widget?> navRelation = {
      NavComponents.navigation: navigation,
      NavComponents.scrollview: scrollView,
    };

    // appBarRelation supposed to control elements on top of the screen,
    // which are inserted into scrollview
    Map<AppBarComponents, Widget?> appBarRelation = {
      AppBarComponents.actionButton: widget.actionButton,
      AppBarComponents.topButton: topButton,
      AppBarComponents.header: widget.header,
      AppBarComponents.title: Text(widget.title ?? ''),
    };

    // Wrap widgets with LayoutIds

    Map<Map<Enum, Widget?>, List<Widget>> layouts = {
      navRelation: [],
      appBarRelation: [],
    };

    layouts.forEach((key, value) {
      key.forEach((id, child) {
        if (child != null) value.add(LayoutId(id: id, child: child));
      });
    });

    // TODO: wallaper adaptation
    return ColoredBox(
      color: theme.backgroundColor,
      child: CustomMultiChildLayout(
        delegate: _NavScaffoldDelegate(),
        children: layouts[navRelation]!,
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
    Size titleSize = Size.zero;

    // LAYOUT NAVIGATION

    BoxConstraints constraints = BoxConstraints.tightFor(
      height: size.height - titleSize.height,
    );

    Offset offset = Offset(
      wideInterface ? 0 : 0 - navSize.width,
      titleSize.height + 100,
    );

    navSize = setChild(NavComponents.navigation, offset, constraints);

    return;
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

class _AppBarScaffoldDelegate extends MultiChildLayoutDelegate {
  Size setChild(Object childId, Offset offset, BoxConstraints constraints) {
    positionChild(childId, offset);
    return layoutChild(childId, constraints);
  }

  @override
  void performLayout(Size size) {
    if (hasChild(AppBarComponents.actionButton)) {
      positionChild(AppBarComponents.actionButton, Offset.zero);
      layoutChild(AppBarComponents.actionButton, BoxConstraints.loose(size));
    }
    if (hasChild(AppBarComponents.header)) {
      positionChild(AppBarComponents.header, Offset.zero);
      layoutChild(AppBarComponents.header, BoxConstraints.loose(size));
    }
    if (hasChild(AppBarComponents.title)) {
      positionChild(AppBarComponents.title, Offset.zero);
      layoutChild(AppBarComponents.title, BoxConstraints.loose(size));
    }
    if (hasChild(AppBarComponents.topButton)) {
      positionChild(AppBarComponents.topButton, Offset.zero);
      layoutChild(AppBarComponents.topButton, BoxConstraints.loose(size));
    }

    return;
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

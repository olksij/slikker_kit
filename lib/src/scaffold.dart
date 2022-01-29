import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slikker_kit/slikker_kit.dart';

import './theme.dart';
import './top_button.dart';

enum _Comps { navigation, actionButton, topButton, content, title, header, fab }

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

    Map<_Comps, Widget?> relation = {
      _Comps.navigation: const Text('nav'),
      _Comps.actionButton: widget.actionButton,
      _Comps.topButton: const Text('topButton'),
      _Comps.content: widget.content,
      _Comps.title: Text(widget.title ?? 'title'),
      _Comps.header: widget.header,
      _Comps.fab: widget.actionButton,
    };

    List<Widget> children = [];

    relation.forEach((id, child) {
      if (child != null) children.add(LayoutId(id: id, child: child));
    });

    return CustomMultiChildLayout(
      delegate: _ScaffolderDelegate(),
      children: children,
    );
  }
}

class _ScaffolderDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    // TODO: Detect low reachability interface
    const bool highReach = true;

    bool wideInterface = size.width > 480;

    Size navSize = Size.zero;
    Size titleSize = Size.zero;

    if (hasChild(_Comps.navigation)) {
      navSize = layoutChild(_Comps.navigation, BoxConstraints.loose(size));
      positionChild(
        _Comps.navigation,
        Offset(
          wideInterface ? 0 : 0 - navSize.width,
          titleSize.height,
        ),
      );
    }

    if (hasChild(_Comps.actionButton)) {
      positionChild(_Comps.actionButton, Offset.zero);
      layoutChild(_Comps.actionButton, BoxConstraints.loose(size));
    }
    if (hasChild(_Comps.content)) {
      positionChild(_Comps.content, Offset.zero);
      layoutChild(_Comps.content, BoxConstraints.loose(size));
    }
    if (hasChild(_Comps.fab)) {
      positionChild(_Comps.fab, Offset.zero);
      layoutChild(_Comps.fab, BoxConstraints.loose(size));
    }
    if (hasChild(_Comps.header)) {
      positionChild(_Comps.header, Offset.zero);
      layoutChild(_Comps.header, BoxConstraints.loose(size));
    }
    if (hasChild(_Comps.title)) {
      positionChild(_Comps.title, Offset.zero);
      layoutChild(_Comps.title, BoxConstraints.loose(size));
    }
    if (hasChild(_Comps.topButton)) {
      positionChild(_Comps.topButton, Offset.zero);
      layoutChild(_Comps.topButton, BoxConstraints.loose(size));
    }

    return;
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

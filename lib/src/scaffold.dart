import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'top_button.dart';

/// Constructor, which creates `TopButtonWidget`. The widget will be displayed
/// in the top of the page. When user pulls the page or taps the widget,
/// `TopButton.action` will be fired.
class TopButton {
  /// `TopButton`'s title. Usually text that hints which action will be taken
  /// when user taps the button or pulls the page.
  final String? title;

  /// `TopButton`'s icon. Usually used for hinting which action will be taken
  /// when user taps the button or pulls the page.
  final IconData? icon;

  /// The function that will be called when user pulls the page or taps the
  /// `TopButton`.
  final Function? action;

  late final bool isHidden;

  TopButton({
    required this.title,
    required this.icon,
    required this.action,
  }) : isHidden = false;

  /// That function allows to hide the button.
  TopButton.hidden()
      : isHidden = true,
        title = null,
        icon = null,
        action = null;
}

/// Widget that helps to build a page.
/// Full documentation will be later
class SlikkerScaffold extends StatefulWidget {
  /// Text that is displayed above `header`. Useally is a text which
  /// indicates which page is it. In Material design it wuld be `AppBarTitle`
  late final String title;

  /// Widget that is displayed above `content`. In Material Design it
  /// is usually `AppBar`.
  late final Widget header;

  /// Widget, usually `ListView`/`GridView` that contains other widgets.
  /// Content of the page.
  late final Widget content;

  /// Constructor, which creates `TopButtonWidget`. The widget will be displayed
  /// in the top of the page. When user pulls the page or taps the widget,
  /// `TopButton.action` will be fired.
  ///
  /// If you want to **hide** the button, use `TopButton.hidden()`.
  late final TopButton topButton;

  /// Widget that is placed in the bottom of the screen, always visible, and
  /// floats above the `content`.
  late final Widget floatingButton;

  SlikkerScaffold({
    required this.topButton,
    required this.title,
    required this.header,
    required this.content,
    required this.floatingButton,
  });

  @override
  _SlikkerScaffoldState createState() => _SlikkerScaffoldState();
}

class _SlikkerScaffoldState extends State<SlikkerScaffold> {
  late final Function refreshTopButton;

  int _scrollPreviousPercent = 0;
  bool _scrollActionFired = false;
  bool _scrollTopHaptic = false;

  bool scrolled(ScrollNotification info) {
    int percent = -info.metrics.pixels.round();

    if (percent < 0)
      percent = 0;
    else {
      percent = (percent > 100 ? 100 : percent);
      if (_scrollTopHaptic != (percent == 100)) {
        _scrollTopHaptic = percent == 100;
        HapticFeedback.lightImpact();
        if (!_scrollTopHaptic) _scrollActionFired = false;
      }
    }

    if (info is ScrollUpdateNotification &&
        (percent != _scrollPreviousPercent || info.dragDetails == null) &&
        info.metrics.axisDirection == AxisDirection.down &&
        !widget.topButton.isHidden) {
      refreshTopButton(percent);
      _scrollPreviousPercent = percent;
      if (info.dragDetails == null && percent == 100 && !_scrollActionFired) {
        widget.topButton.action!();
        _scrollActionFired = true;
      }
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFF6F6FC),
      child: SafeArea(
        top: true,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) => scrolled(scrollInfo),
              child: ListView(
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                children: <Widget>[
                  Container(height: 52),
                  if (!widget.topButton.isHidden)
                    Center(
                      child: TopButtonWidget(
                        title: widget.topButton.title!,
                        icon: widget.topButton.icon!,
                        accent: 240,
                        onTap: widget.topButton.action!,
                        refresh: (Function topButtonFunction) => refreshTopButton = topButtonFunction,
                      ),
                    ),
                  Container(height: MediaQuery.of(context).size.height / 3.7),
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 36.0),
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 20),
                  widget.header,
                  Padding(
                    child: widget.content,
                    padding: EdgeInsets.all(30),
                  ),
                  Container(height: 60)
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment(0, 0.25),
                        colors: [Color(0x00F6F6FC), Color(0xFFF6F6FC)])),
                height: 84,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: widget.floatingButton,
                margin: EdgeInsets.only(bottom: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
  late bool pull100;
  late bool pullAct;
  late bool active;
  late Function refreshTopButton;

  @override
  void initState() {
    super.initState();
    pull100 = pullAct = active = false;
  }

  bool scrolled(ScrollNotification info) {
    if (widget.topButton.isHidden) return true;

    int percent = -info.metrics.pixels.round();
    if (info is ScrollUpdateNotification && active) {
      if (percent >= 100 && !pull100) {
        HapticFeedback.lightImpact();
        pull100 = pullAct = true;
      }

      if (percent < 100 && pull100) pull100 = pullAct = false;

      if (info.dragDetails == null && pullAct) {
        pullAct = false;
        widget.topButton.action!();
      }
      refreshTopButton(percent);
    }
    if (info is ScrollStartNotification) active = percent >= 0;
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
                              refreshFunction: (Function topButtonFunction) => refreshTopButton = topButtonFunction,
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
                    )),
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
                    )),
              ],
            )));
  }
}

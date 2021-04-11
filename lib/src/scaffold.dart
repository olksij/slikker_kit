import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'top_button.dart';

/// Widget that helps to build a page.
/// Full documentation will be later
class SlikkerScaffold extends StatefulWidget {
  /// Text that is displayed above `header`. Useally is a text which
  /// indicates which page is it. In Material design it wuld be `AppBarTitle`
  final String? title;

  /// Custom title widget, that is placed above `header`.
  final Widget? customTitle;

  /// Widget that is displayed above `content`. In Material Design it
  /// is usually `AppBar`.
  final Widget? header;

  /// Widget, usually `ListView`/`GridView` that contains other widgets.
  /// Content of the page.
  final Widget? content;

  /// `TopButton`'s title. Usually text that hints which action will be taken
  /// when user taps the button or pulls the page.
  final String? topButtonTitle;

  /// `TopButton`'s icon. Usually used for hinting which action will be taken
  /// when user taps the button or pulls the page.
  final IconData? topButtonIcon;

  /// The function that will be called when user pulls the page or taps the
  /// `TopButton`.
  final Function? topButtonAction;

  /// Widget that is placed in the bottom of the screen, always visible, and
  /// floats above the `content`.
  final Widget? floatingButton;

  SlikkerScaffold({
    this.title,
    this.header,
    this.content,
    this.topButtonAction,
    this.floatingButton,
    this.topButtonTitle,
    this.topButtonIcon,
    this.customTitle,
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
    int percent = -info.metrics.pixels.round();
    if (info is ScrollUpdateNotification && active) {
      if (percent >= 100 && !pull100) {
        HapticFeedback.lightImpact();
        pull100 = pullAct = true;
      }

      if (percent < 100 && pull100) pull100 = pullAct = false;

      if (info.dragDetails == null && pullAct) {
        pullAct = false;
        widget.topButtonAction!();
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
                        Center(
                            child: TopButton(
                          title: widget.topButtonTitle ?? "Hello",
                          icon: widget.topButtonIcon ?? Icons.settings,
                          accent: 240,
                          onTap: widget.topButtonAction ?? () {},
                          refreshFunction: (Function topButtonFunction) => refreshTopButton = topButtonFunction,
                        )),
                        Container(height: MediaQuery.of(context).size.height / 3.7),
                        widget.customTitle ??
                            (widget.title != null
                                ? Text(
                                    widget.title!,
                                    style: TextStyle(fontSize: 36.0),
                                    textAlign: TextAlign.center,
                                  )
                                : Container()),
                        Container(height: 20),
                        widget.header ?? Container(),
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

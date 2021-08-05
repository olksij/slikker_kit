import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'top_button.dart';

// TODO: Fix [SlikkerScaffold] structure.

/// Constructor, which creates `TopButtonWidget`. The widget will be displayed
/// in the top of the page. When user pulls the page or taps the widget,
/// `TopButton.action` will be fired.
class TopButton {
  /// `TopButton`'s title. Usually text that hints which action will be taken
  /// when user taps the button or pulls the page.
  final String title;

  /// `TopButton`'s icon. Usually used for hinting which action will be taken
  /// when user taps the button or pulls the page.
  final IconData icon;

  /// The function that will be called when user pulls the page or taps the
  /// `TopButton`.
  final Function action;

  late final bool isHidden;

  TopButton({
    required this.title,
    required this.icon,
    required this.action,
  }) : isHidden = false;
}

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

  /// Constructor, which creates `TopButtonWidget`. The widget will be displayed
  /// in the top of the page. When user pulls the page or taps the widget,
  /// `TopButton.action` will be fired.
  // If you want to **hide** the button, use `TopButton.hidden()`.
  final TopButton? topButton;

  /// Widget that is placed in the bottom of the screen, always visible, and
  /// floats above the `content`.
  final Widget? floatingButton;

  final bool sliver;

  SlikkerScaffold({
    this.topButton,
    this.title,
    this.header,
    this.content,
    this.floatingButton,
  }) : sliver = false;

  /// Content of the page must be **Sliver** widget.
  SlikkerScaffold.sliver({
    this.topButton,
    this.title,
    this.header,
    this.content,
    this.floatingButton,
  }) : sliver = true;

  @override
  _SlikkerScaffoldState createState() => _SlikkerScaffoldState();
}

class _SlikkerScaffoldState extends State<SlikkerScaffold> {
  late Function refreshTopButton;

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
        if (!_scrollTopHaptic)
          _scrollActionFired = false;
        else
          HapticFeedback.lightImpact();
      }
    }

    if (info is ScrollUpdateNotification &&
        (percent != _scrollPreviousPercent || info.dragDetails == null) &&
        info.metrics.axisDirection == AxisDirection.down &&
        widget.topButton != null) {
      refreshTopButton(percent);
      _scrollPreviousPercent = percent;
      if (info.dragDetails == null && percent == 100 && !_scrollActionFired) {
        widget.topButton!.action();
        _scrollActionFired = true;
      }
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HSVColor.fromAHSV(1, 240, 0.05, 0.98).toColor(),
      child: SafeArea(
        top: true,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) => scrolled(scrollInfo),
              child: CustomScrollView(
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: (widget.topButton == null)
                            ? Container(height: 38)
                            : Center(
                                child: TopButtonWidget(
                                  title: widget.topButton!.title,
                                  icon: widget.topButton!.icon,
                                  accent: 240,
                                  onTap: widget.topButton!.action,
                                  refresh: (Function topButtonFunction) =>
                                      refreshTopButton = topButtonFunction,
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 5,
                        ),
                      ),
                      Text(
                        widget.title ?? '',
                        style: TextStyle(fontSize: 36.0),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: EdgeInsets.all(30),
                        child: widget.header,
                      ),
                    ]),
                  ),
                  SliverPadding(
                    sliver: widget.sliver
                        ? widget.content
                        : SliverToBoxAdapter(
                            child: widget.content,
                          ),
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
                  ),
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
                    colors: [
                      HSVColor.fromAHSV(0, 240, 0.04, 0.98).toColor(),
                      HSVColor.fromAHSV(1, 240, 0.04, 0.98).toColor(),
                    ],
                  ),
                ),
                height: 84,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: widget.floatingButton,
                margin: EdgeInsets.only(bottom: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

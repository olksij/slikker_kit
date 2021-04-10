import 'package:flutter/material.dart';
import 'card.dart';
import 'get_color.dart';

class TopButton extends StatefulWidget {
  final String? title;
  final IconData? icon;
  final double? accent;
  final Function? onTap;
  final Function? refreshFunction;

  TopButton({this.title, this.icon, this.accent, this.onTap, this.refreshFunction});

  @override
  TopButtonState createState() => TopButtonState();
}

class TopButtonState extends State<TopButton> with TickerProviderStateMixin {
  late AnimationController scrollController;
  late CurvedAnimation scrollAnimation;

  int percent = 0;
  Color? color;

  void refresh(p) {
    if (percent != p && this.mounted) setState(() => percent = p);
  }

  @override
  void initState() {
    super.initState();
    widget.refreshFunction!(refresh);
    color = getColor(1, widget.accent!, 0.4, 0.2);
    scrollController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );

    scrollAnimation = CurvedAnimation(curve: Curves.easeOut, parent: scrollController);
    scrollAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (scrollAnimation.value == 0 && percent > 10) scrollController.forward();
    if (scrollAnimation.value == 1 && percent < 10) scrollController.reverse();
    return SlikkerCard(
      accent: 240,
      borderRadius: BorderRadius.circular(52),
      isFloating: false,
      onTap: this.widget.onTap,
      padding: EdgeInsets.fromLTRB(14, 13, 17, 14),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Stack(
          children: [
            Icon(
              widget.icon,
              color: color!.withAlpha(255 - (scrollAnimation.value * 255).toInt()),
              size: 22,
            ),
            Padding(
              padding: EdgeInsets.all(3),
              child: Transform.rotate(
                angle: 2.8 + percent / 100 * 3.55,
                child: SizedBox(
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(color!.withAlpha((scrollAnimation.value * 255).toInt())),
                  ),
                  height: 16,
                  width: 16,
                ),
              ),
            ),
          ],
        ),
        Container(width: 8, height: 24),
        Text(widget.title!, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16))
      ]),
    );
  }
}

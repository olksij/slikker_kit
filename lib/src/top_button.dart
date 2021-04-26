import 'package:flutter/material.dart';
import 'card.dart';
import 'get_color.dart';

class TopButtonWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final double accent;
  final Function onTap;
  final Function refresh;
  final Color color;

  TopButtonWidget({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.refresh,
  }) : color = getColor(a: 1, h: accent, s: 0.4, v: 0.2);

  @override
  Widget build(BuildContext context) {
    return SlikkerCard(
      accent: accent,
      borderRadius: BorderRadius.circular(52),
      isFloating: false,
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(14, 13, 17, 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopButtonIcon(
            icon: icon,
            color: color,
            refresh: refresh,
          ),
          Container(width: 8, height: 24),
          Text(title,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }
}

class _TopButtonIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Function refresh;

  _TopButtonIcon({
    required this.icon,
    required this.color,
    required this.refresh,
  });

  @override
  _TopButtonIconState createState() => _TopButtonIconState();
}

class _TopButtonIconState extends State<_TopButtonIcon>
    with TickerProviderStateMixin {
  late AnimationController scrollController;
  late CurvedAnimation scrollAnimation;

  int percent = 0;

  void refresh(p) {
    if (this.mounted) setState(() => percent = p);
  }

  @override
  void initState() {
    super.initState();
    widget.refresh(refresh);

    scrollController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );

    scrollAnimation =
        CurvedAnimation(curve: Curves.easeOut, parent: scrollController);
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
    return Stack(
      children: [
        Icon(
          widget.icon,
          color: widget.color
              .withAlpha(255 - (scrollAnimation.value * 255).toInt()),
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
                valueColor: AlwaysStoppedAnimation<Color>(widget.color
                    .withAlpha((scrollAnimation.value * 255).toInt())),
              ),
              height: 16,
              width: 16,
            ),
          ),
        ),
      ],
    );
  }
}

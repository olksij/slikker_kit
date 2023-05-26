import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';

import './button.dart';
import './theme.dart';

// TODO: Extend [SlikkerButton].
// TODO: Remaster [TopButtonWidget] structure.
// TODO: Move to scaffold.dart.

class TopButtonWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;
  final Function refresh;

  const TopButtonWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.refresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = SLTheme.of(context);
    final color = HSVColor.fromAHSV(1, 240, 0.4, 0.2).toColor();

    return SlikkerButton(
      shape: BoxShape.circle,
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      icon: _TopButtonIcon(
        icon: icon,
        color: color,
        refresh: refresh,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _TopButtonIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Function refresh;

  const _TopButtonIcon({
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
    if (mounted) setState(() => percent = p);
  }

  @override
  void initState() {
    super.initState();
    widget.refresh(refresh);

    scrollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
          padding: const EdgeInsets.all(3),
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

import 'package:slikker_kit/slikker_kit.dart';

// TODO: Documentation
class Slide extends StatelessWidget {
  final Widget regular;
  final Widget state;
  final Animation<double> animation;
  final bool opacity;
  final Map<Widget, Tween<Offset>> relation;

  Slide({
    super.key,
    required this.animation,
    this.regular = const SizedBox(),
    this.state = const SizedBox(),
    this.opacity = true,
  }) : relation = {regular: regularPosition, state: statePosiiton};

  static final regularPosition = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, -1),
  );

  static final statePosiiton = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    final animated = AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final children = <Widget>[];

        for (final widget in relation.entries) {
          children.add(
            SlideTransition(
              position: widget.value.animate(animation),
              child: widget.key,
            ),
          );
        }
        return Stack(
          alignment: Alignment.center,
          children: children,
        );
      },
    );

    return ClipRect(clipBehavior: Clip.hardEdge, child: animated);
  }
}

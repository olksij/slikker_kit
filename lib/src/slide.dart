import 'package:slikker_kit/slikker_kit.dart';
import 'package:flutter/material.dart';

/// A widget that slides between two given Widgets with an optional opacity effect.
///
/// The class takes in five parameters: `regular`, `state`, `animation`, `opacity`, and `relation`.
/// - `regular`: An initial widget that is displayed when the [animation.value] is 0.
/// - `state`: An animated widget that is displayed after the animation completes.
/// - `animation`: The animation used to animate the transition from `regular` to `state`.
/// - `opacity`: Controls whether or not to add an opacity effect in the transition animation.
/// - `relation`: A map linking the `regular` and `state` widgets to their corresponding position transitions with a Tween object.
class Slide extends StatelessWidget {
  /// An initial widget that is displayed when the [animation.value] is 0.
  final Widget regular;

  /// An animated widget that is displayed after the [animation] completes
  final Widget state;

  /// Controls the transition between the states.
  final Animation<double> animation;

  /// Controls whether or not to add an opacity effect in the transition animation.
  final bool opacity;

  /// A map linking the `regular` and `state` widgets to their corresponding position transitions with a Tween object.
  final Map<Widget, Tween<Offset>> relation;

  /// Creates a [Slide] widget.
  ///
  /// The [animation], [regular], and [state] parameters must not be null.
  Slide({
    super.key,
    required this.animation,
    this.regular = const SizedBox(),
    this.state = const SizedBox(),
    this.opacity = true,
  }) : relation = {regular: _regularPosition, state: _statePosition};

  static final _regularPosition = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, -1),
  );

  static final _statePosition = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: AnimatedBuilder(
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
      ),
    );
  }
}

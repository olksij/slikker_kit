import 'package:slikker_kit/slikker_kit.dart';

/// A widget that slides between a list of widgets.
/// Used to display a state of user interaction in Slikker Design System.
class Slide extends StatefulWidget {
  /// A list of widgets to be displayed in the Slide widget.
  final List<Widget> widgets;

  /// The initial index of the widget in `widget.widgets`.
  final int? initial;

  /// A constructor for creating a Slide widget.
  /// The `widgets` and `callback` parameters are required.
  Slide({required this.widgets, this.initial, GlobalKey? key})
      : super(key: key ?? GlobalKey<_SlideState>());

  /// A static method for updating the value of a Slide widget.
  /// It finds the nearest _SlideState instance in the widget tree
  /// and calls its [updateValue] method with the [value] parameter.
  void update(int value) => state?.updateValue(value);

  /// A getter for getting the current index of a Slide widget.
  int get index => state?.current ?? initial ?? 0;

  /// A getter for getting the current state of a Slide widget.
  _SlideState? get state => (super.key as GlobalKey<_SlideState>).currentState;

  @override
  State<Slide> createState() => _SlideState();
}

class _SlideState extends State<Slide> {
  /// The current index of the widget in `widget.widgets`.
  late int current;

  @override
  void initState() {
    current = widget.initial ?? 0;
    super.initState();
  }

  /// A method for updating the value of [_SlideState.current].
  void updateValue(int value) => setState(() => current = value);

  @override
  Widget build(BuildContext context) {
    List<Widget> result = [];

    /// Iterate over each widget in `widget.widgets` along with its index.
    widget.widgets.asMap().forEach((index, widget) {
      final offset = current < index ? .5 : (current > index ? -.5 : .0);

      result.add(Center(
        child: AnimatedOpacity(
          opacity: index == current ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 600),
            curve: const SlikkerCurve(type: CurveType.curveOut),
            offset: Offset.zero.translate(0, offset),
            child: widget,
          ),
        ),
      ));
    });

    // Return a ClipRect with a Stack of widgets.
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: Stack(
        alignment: Alignment.center,
        children: result,
      ),
    );
  }
}

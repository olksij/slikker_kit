import 'package:flutter/material.dart';
import 'package:slikker_kit/slikker_kit.dart';

void main() => runApp(SlikkerExampleApp());

Color getColor(double a, double h, double s, double v) =>
    HSVColor.fromAHSV(a, h, s, v).toColor();

class SlikkerExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slikker App Example',
      theme: ThemeData(fontFamily: 'Manrope'),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final double accent = 240;
  @override
  Widget build(BuildContext context) {
    return SlikkerScaffold(
      content: Container(),
      topButtonAction: () {},
      topButtonIcon: Icons.clear,
      topButtonTitle: 'Clear',
      title: 'Example App',
      floatingButton: SlikkerCard(
        accent: accent,
        borderRadius: BorderRadius.circular(50),
        child: Text('Tap!'),
        padding: EdgeInsets.all(17),
      ),
      header: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: SlikkerCard(
          accent: accent,
          padding: EdgeInsets.all(15),
          child: PushedButton(
            accent: accent,
            count: 1,
          ),
        ),
      ),
    );
  }
}

class PushedButton extends StatefulWidget {
  final int count;
  final double accent;

  const PushedButton({this.count, this.accent});
  @override
  _PushedButtonState createState() => _PushedButtonState();
}

class _PushedButtonState extends State<PushedButton> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('When your day starts?',
          style: TextStyle(
              fontSize: 17, color: getColor(1, widget.accent, 0.4, 0.4))),
      Expanded(child: Container()),
      SlikkerCard(
        accent: 240,
        isFloating: false,
        borderRadius: BorderRadius.circular(8),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text(widget.count.toString(),
            style: TextStyle(
                fontSize: 15, color: getColor(1, widget.accent, 0.4, 0.4))),
      ),
    ]);
  }
}

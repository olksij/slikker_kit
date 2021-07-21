import 'package:flutter/material.dart';
import 'package:slikker_kit/slikker_kit.dart';

void main() => runApp(SlikkerExampleApp());

Color getColor(double a, double h, double s, double v) =>
    HSVColor.fromAHSV(a, h, s, v).toColor();

class SlikkerExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //showPerformanceOverlay: true,
      //checkerboardOffscreenLayers: true,
      title: 'Slikker App Example',
      theme: ThemeData(fontFamily: 'Manrope'),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double accent = 240;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return SlikkerScaffold(
      topButton: TopButton(
        action: () => setState(() => count = 0),
        icon: Icons.clear,
        title: 'Clear',
      ),
      title: 'Example',
      floatingButton: SlikkerButton(
        accent: accent,
        borderRadius: BorderRadius.circular(26),
        child: Text('Tap!'),
        onTap: () => setState(() => count++),
        padding: EdgeInsets.all(17),
      ),
      header: SlikkerContainer(
        accent: accent,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17),
                child: Text(
                  'Button taps:',
                  style: TextStyle(
                    fontSize: 17,
                    color: getColor(1, accent, 0.4, 0.4),
                  ),
                ),
              ),
            ),
            SlikkerButton(
              accent: 240,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 17,
                  color: getColor(1, accent, 0.4, 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

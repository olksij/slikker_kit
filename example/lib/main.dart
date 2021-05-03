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
      floatingButton: SlikkerCard(
        accent: accent,
        borderRadius: BorderRadius.circular(50),
        child: Text('Tap!'),
        onTap: () => setState(() => count++),
        padding: EdgeInsets.all(17),
      ),
      header: SlikkerCard(
        accent: accent,
        padding: EdgeInsets.fromLTRB(20, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Button taps:',
                style: TextStyle(
                  fontSize: 17,
                  color: getColor(1, accent, 0.4, 0.4),
                ),
              ),
            ),
            SlikkerCard(
              accent: 240,
              isFloating: false,
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 15,
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

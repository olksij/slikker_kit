import 'package:slikker_kit/slikker_kit.dart';

void main() => runApp(const SlikkerExampleApp());

Color getColor(double a, double h, double s, double v) =>
    HSVColor.fromAHSV(a, h, s, v).toColor();

class SlikkerExampleApp extends StatelessWidget {
  const SlikkerExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlikkerApp(
      //showPerformanceOverlay: true,
      //checkerboardOffscreenLayers: true,
      title: 'Slikker App Example',
      theme: SlikkerThemeData(fontFamily: 'Manrope'),
      initialRoute: '',
      //routes: {'/': (context) => const HomePage()},
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return SlikkerScaffold(
      title: 'Example',
      /*floatingButton: SlikkerButton(
        borderRadius: BorderRadius.circular(26),
        child: const Text('Tap!'),
        onTap: () => setState(() => count++),
        padding: const EdgeInsets.all(17),
      ),*/
      header: SlikkerContainer(
        child: Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17),
                child: Text(
                  'Button taps:',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            SlikkerButton(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
              onTap: () => setState(() => count++),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
              child: Text(
                count.toString(),
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

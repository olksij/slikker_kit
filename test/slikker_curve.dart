import 'package:slikker_kit/slikker_kit.dart';
import 'package:test/test.dart';

void main() {
  group('SlikkerCurve', () {
    test('transform should return 0.5 when t is 0', () {
      const SlikkerCurve curve = SlikkerCurve();
      expect(curve.transform(0), equals(0.5));
    });

    test('transform should return 1 when t is 1', () {
      const SlikkerCurve curve = SlikkerCurve();
      expect(curve.transform(1), equals(1));
    });

    test('transform should return -1 when t is -1', () {
      const SlikkerCurve curve = SlikkerCurve();
      expect(curve.transform(-1), equals(-1));
    });

    test('start should return 0.0833', () {
      const SlikkerCurve curve = SlikkerCurve();
      expect(curve.start, equals(0.0833));
    });

    test(
        'transformInternal should throw an exception when t is outside of [-1, 1] range',
        () {
      const SlikkerCurve curve = SlikkerCurve();
      expect(curve.transformInternal(1.1), AssertionError());
    });
  });
}

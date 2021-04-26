import 'package:flutter/widgets.dart';

Color getColor({
  required double a,
  required double h,
  required double s,
  required double v,
}) =>
    HSVColor.fromAHSV(a, h, s, v).toColor();

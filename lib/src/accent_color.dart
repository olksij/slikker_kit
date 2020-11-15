import 'package:flutter/widgets.dart';

Color accentColor(double a, double h, double s, double v) => HSVColor.fromAHSV(a, h, s, v).toColor();
import 'dart:math';
import 'package:flutter/material.dart';

class SinCurve extends Curve {
  @override
  double transformInternal(double t) {
    return sin(t * 3);
  }
}

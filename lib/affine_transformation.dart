import 'dart:math';

import 'package:flutter/material.dart';

class Coefficients {
  final double a;
  final double b;
  final double c;
  final double d;
  final double e;
  final double f;

  final Color color;

  Coefficients({required this.a, required this.b, required this.c, required this.d, required this.e, required this.f, required this.color});
}

class AffineTransformation {

  List<Coefficients> generate(int count, Random random) {
    final List<Coefficients> coefficients = [];
    for (int i = 0; i < count; i++) {
      double a = random.nextDouble() * 2 - 1;
      double b = random.nextDouble() * 2 - 1;
      double c = random.nextDouble() * 2 - 1;
      double d = random.nextDouble() * 2 - 1;
      double e = random.nextDouble() * 2 - 1;
      double f = random.nextDouble() * 2 - 1;

      do {
        //a^2+d^2<1
        do {
          a = random.nextDouble() * 2 - 1;
          d = random.nextDouble() * 2 - 1;
        }
        while (!((pow(a, 2) + pow(d, 2)) < 1));

        //b^2+e^2<1
        do {
          b = random.nextDouble() * 2 - 1;
          e = random.nextDouble() * 2 - 1;
        }
        while (!((pow(b, 2) + pow(e, 2)) < 1));
      }
      while (!((pow(a, 2) + pow(b, 2) + pow(d, 2) + pow(e, 2)) < (1 + pow(a * e - b * d, 2))));

      c = random.nextDouble() * 2 - 1;
      f = random.nextDouble() * 2 - 1;

      int rc = 0, gc = 0, bc = 0, mid = 0;
      while (sqrt(pow(rc - mid, 2) + pow(gc - mid, 2) + pow(bc - mid, 2)) < 50) {
        rc = random.nextInt(255);
        gc = random.nextInt(255);
        bc = random.nextInt(255);
        mid = (rc + gc + bc) ~/ 3;
      }

      final coefficient = Coefficients(a: a, b: b, c: c, d: d, e: e, f: f, color: Color.fromRGBO(rc, gc, bc, 1));
      coefficients.add(coefficient);
    }

    return coefficients;
  }
}
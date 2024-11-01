import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fractal_flame/drawer.dart';
import 'package:fractal_flame/id_generator.dart';
import 'package:fractal_flame/pixel.dart';

class MyPainter extends CustomPainter  {

  final Map<Point, Pixel> generateImage;

  MyPainter({super.repaint, required this.generateImage});

  @override
  void paint(Canvas canvas, Size size) {
    for (int y = 0; y < size.height.toInt(); y++) {
      for (int x = 0; x < size.width.toInt(); x++) {
        canvas.drawPoints(
          PointMode.points,
          [ Offset(x.toDouble(), y.toDouble()),],
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = Color.fromRGBO(generateImage[Point(x,y)]!.r, generateImage[Point(x,y)]!.g, generateImage[Point(x,y)]!.b, 1),
        );
      }
    }

    print("DONE");
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => false;
}

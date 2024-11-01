import 'dart:math';

import 'package:dart_numerics/dart_numerics.dart';
import 'package:flutter/material.dart';
import 'package:fractal_flame/affine_transformation.dart';
import 'package:fractal_flame/pixel.dart';

abstract class MyDrawer {

  static Map<Point, Pixel> generateImage(int id, Size size) {

    Random random = Random(id);

    final affineTransformations = AffineTransformation().generate(20, random);

    Map<Point, Pixel> pixelMap = {};
    for (int y = 0; y < size.height; y++) {
      for (int x = 0; x < size.width; x++) {
        pixelMap[Point(x, y)] = Pixel();
      }
    }

    double yMax = 1,                                              yMin = -yMax;
    double xMax = size.height.toDouble() / size.width.toDouble(), xMin = -xMax;

    double newX = random.nextDouble() * (xMax - xMin) + xMin;
    double newY = random.nextDouble() * (yMax - yMin) + yMin;

    int countOfStepsScaleModifier = 10;

    var iterations =size. width * size.height * countOfStepsScaleModifier;
    for (int step = -20; step < iterations; step++) {
      // print("$step/$iterations");
      int i = random.nextInt(affineTransformations.length);

      newX = affineTransformations[i].a * newX + affineTransformations[i].b * newY + affineTransformations[i].c;
      newY = affineTransformations[i].d * newX + affineTransformations[i].e * newY + affineTransformations[i].f;

      Point p = sphere(newX, newY);
      newX = p.x.toDouble();
      newY = p.y.toDouble();

      if (step >= 0 && xMin <= newX && newX <= xMax && yMin <= newY && newY <= yMax) {

        int x1 = (size.width * (1 - ((xMax - newX) / (xMax - xMin)))).toInt();
        int y1 = (size.height * (1 - ((yMax - newY) / (yMax - yMin)))).toInt();
        
        if (x1 < size.width && y1 < size.height) {
          if (pixelMap[Point(x1,y1)]!.counter == 0) {
            pixelMap[Point(x1,y1)]!.r = affineTransformations[i].color.red;
            pixelMap[Point(x1,y1)]!.g = affineTransformations[i].color.green;
            pixelMap[Point(x1,y1)]!.b = affineTransformations[i].color.blue;
          } else {
            pixelMap[Point(x1,y1)]!.r = (pixelMap[Point(x1,y1)]!.r + affineTransformations[i].color.red) ~/ 2;
            pixelMap[Point(x1,y1)]!.g = (pixelMap[Point(x1,y1)]!.g + affineTransformations[i].color.green) ~/ 2;
            pixelMap[Point(x1,y1)]!.b = (pixelMap[Point(x1,y1)]!.b + affineTransformations[i].color.blue) ~/ 2;
          }
          pixelMap[Point(x1,y1)]!.counter++;
        }
      }
    }

    double maxValue = 0.0;
    for (int y = 0; y < size.height; y++) {
      for (int x = 0; x < size.width; x++) {
        if (pixelMap[Point(x,y)]!.counter != 0) {
          pixelMap[Point(x,y)]!.normal = log10(pixelMap[Point(x,y)]!.counter);
          maxValue = max(maxValue, pixelMap[Point(x,y)]!.normal);
        }
      }
    }

    const double gamma = 2.2;
    const double correctionValue = 1.0 / gamma;
    for (int y = 0; y < size.height; y++) {
      for (int x = 0; x < size.width; x++) {
        final pixel = pixelMap[Point(x,y)]!;

        pixel.normal = pixel.normal / maxValue;
        final multiplier = pow(pixel.normal, correctionValue);

        pixel.r = (pixel.r * multiplier).toInt();
        pixel.g = (pixel.g * multiplier).toInt();
        pixel.b = (pixel.b * multiplier).toInt();
      }
    }

    return pixelMap;
  }

  static Point sphere(double x, double y) {
    return Point(x / (pow(x, 2) + pow(y, 2)), y / (pow(x, 2) + pow(y, 2)),);
    // return Point(sin(x), sin(y));
  }
}

import 'package:flutter/material.dart';

extension SizeExtension on BuildContext {
  // Screen width & height
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  // Width & Height (no percentage)
  double w(double value) => value;
  double h(double value) => value;

  // Padding Horizontal + Vertical
  double padH(double value) => value;
  double padV(double value) => value;

  // 🔥 Padding All (always in pixels)
  EdgeInsets padAll(double value) => EdgeInsets.all(value);

  // Padding symmetric
  EdgeInsets padSym({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  // Radius
  double radius(double value) => value;

  // Text size (only numbers)
  double text(double value) => value;

  // Predefined spacing (pixels)
  double get s4 => 4;
  double get s8 => 8;
  double get s12 => 12;
  double get s16 => 16;
  double get s20 => 20;

  // Predefined text sizes
  double get smallText => 12;
  double get mediumText => 16;
  double get largeText => 20;
}

// padding: context.padAll(20), // 20 px
// borderRadius: BorderRadius.circular(context.radius(12)),
// padding: context.padSym(h: 10, v: 30),
// height: context.h(200),
// width: context.w(150),

import 'package:flutter/material.dart';

// Matrix4 tween helper
class Matrix4Tween extends Tween<Matrix4> {
  Matrix4Tween({super.begin, super.end});
  @override
  Matrix4 lerp(double t) {
    final a = begin!;
    final b = end!;
    final out = Matrix4.zero();
    final asList = a.storage;
    final bsList = b.storage;
    final outList = out.storage;
    for (var i = 0; i < 16; i++) {
      outList[i] = asList[i] + (bsList[i] - asList[i]) * t;
    }
    return out;
  }
}

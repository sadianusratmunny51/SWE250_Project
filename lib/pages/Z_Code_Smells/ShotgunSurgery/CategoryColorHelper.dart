import 'dart:ui';

import 'package:flutter/material.dart';

class CategoryColorHelper {
  static final List<Color> _availableColors = [Colors.cyan,
  Colors.teal,
  Colors.amber,
  Colors.deepOrange,
  Colors.indigo,
  Colors.lightGreen,
  Colors.pinkAccent,
  Colors.deepPurple,
  Colors.lime,
  Colors.brown,
  Colors.blueGrey,
  Colors.lightBlue,
  Colors.greenAccent,
  Colors.red,
  Colors.yellow,
  Colors.orangeAccent,
  Colors.indigoAccent,
  Colors.blue,
  Colors.tealAccent,
  Colors.purpleAccent,
  Colors.cyanAccent,
  Colors.grey,
  Colors.purple,
  Colors.green,
  Colors.lightGreenAccent,
  Colors.deepOrangeAccent,
  Colors.black,
  Colors.white10,
  Colors.blueAccent,
  Colors.pink,]; // same list as before
  static final Map<String, Color> _categoryColorMap = {};

  static Color getColor(String category) {
    final lower = category.toLowerCase().trim();
    if (_categoryColorMap.containsKey(lower)) {
      return _categoryColorMap[lower]!;
    }

    final usedColors = _categoryColorMap.values.toSet();
    final available = _availableColors.firstWhere(
      (color) => !usedColors.contains(color),
      orElse: () => Colors.grey,
    );

    _categoryColorMap[lower] = available;
    return available;
  }
}

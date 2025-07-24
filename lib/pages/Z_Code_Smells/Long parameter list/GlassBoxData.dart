import 'package:flutter/material.dart';

class GlassBoxData {
  final double width;
  final double height;
  final IconData icon;
  final String title;
  final List<Color> colors;
  final VoidCallback onTap;

  GlassBoxData({
    required this.width,
    required this.height,
    required this.icon,
    required this.title,
    required this.colors,
    required this.onTap,
  });
}

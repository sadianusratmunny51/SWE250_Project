import 'package:flutter/material.dart';

class ActivityCategory {
  final String label;
  final IconData icon;
  final List<Color> colors;

  const ActivityCategory(this.label, this.icon, this.colors);

  static const work = ActivityCategory(
    "Work",
    Icons.work,
    [
      Color.fromARGB(255, 100, 152, 255),
      Colors.blueAccent,
    ],
  );

  static const leisure = ActivityCategory(
    "Leisure",
    Icons.self_improvement,
    [
      Colors.tealAccent,
      Colors.greenAccent,
    ],
  );

  static const entertainment = ActivityCategory(
    "Entertainment",
    Icons.movie,
    [
      Colors.pink,
      Color.fromARGB(255, 252, 29, 252),
    ],
  );

  static const sleep = ActivityCategory(
    "Sleep",
    Icons.night_shelter,
    [
      Color.fromARGB(255, 210, 224, 19),
      Color.fromARGB(255, 218, 161, 17),
    ],
  );

  static const socialMedia = ActivityCategory(
    "Social Media",
    Icons.mobile_friendly,
    [
      Color.fromARGB(255, 12, 231, 235),
      Color.fromARGB(255, 90, 218, 241),
    ],
  );

  static const all = [
    work,
    leisure,
    entertainment,
    sleep,
    socialMedia,
  ];
}

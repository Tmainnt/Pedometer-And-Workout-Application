import 'package:flutter/material.dart';

class WidgetColors {
  Color boxShadowColor() {
    return const Color.fromARGB(255, 158, 158, 158);
  }

  Color iconColor() {
    return const Color.fromARGB(255, 158, 158, 158);
  }

  Color iconColorMoreDark() {
    return const Color.fromARGB(255, 90, 90, 100);
  }

  Color favoriteIcon() {
    return Colors.red;
  }

  List<Color> applicationMainTheme() {
    return [
      Color.fromARGB(255, 124, 139, 253),
      Color.fromARGB(255, 123, 75, 253),
    ];
  }

  Color confirmButton() {
    return Color.fromARGB(255, 97, 126, 255);
  }
}

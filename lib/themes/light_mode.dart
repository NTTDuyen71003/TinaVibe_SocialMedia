import 'package:flutter/material.dart';

class CustomThemeData {
  static Color iconSelectColor = const Color(0xfff36f7d);
  static Color iconDefaultColor = const Color(0xff8592a3);
  static Color getTextColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      // Return a darker shade of black
      return const Color.fromARGB(
          255, 20, 20, 20); // or Colors.black54 for a lighter dark
    } else {
      // Return a darker shade of white
      return Colors.grey.shade100; // or Colors.white54 for a lighter dark
    }
  }
}

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    // surface: Colors.grey.shade300,
    surface: Colors.white,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.grey.shade100,
    inversePrimary: Colors.grey.shade900,
  ),
  scaffoldBackgroundColor: Colors.white,
);

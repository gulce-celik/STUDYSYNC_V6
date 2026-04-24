import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // useMaterial3 is a property that is used to enable the material 3 design.
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      scaffoldBackgroundColor: Colors.white, // scaffoldBackgroundColor is the background color of the scaffold.
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(centerTitle: false), //left
    );
  }
}

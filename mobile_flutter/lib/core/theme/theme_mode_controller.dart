import 'package:flutter/material.dart';

class ThemeModeController extends ChangeNotifier {
  ThemeModeController._();
  static final ThemeModeController instance = ThemeModeController._();

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode nextMode) {
    if (_mode == nextMode) return;
    _mode = nextMode;
    notifyListeners();
  }
}

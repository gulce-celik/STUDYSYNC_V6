import 'package:flutter/foundation.dart';

/// Alt menü sekmesini (Home içinden) programatik seçmek için — Figma/React: Home, Reserve,
/// **Schedule**, Buddy, Profile. Rezervasyonlarım `MyBookingsScreen` ile ayrı sayfa (Home’dan).
class AppTabController extends ChangeNotifier {
  AppTabController._();
  static final AppTabController instance = AppTabController._();

  int _index = 0;
  int get currentIndex => _index;

  void selectTab(int i) {
    if (i == _index) return; // if the index is the same as the current index, return.
    _index = i; // set the index to the new index.
    notifyListeners(); // notify the listeners that the index has changed.
  }
}

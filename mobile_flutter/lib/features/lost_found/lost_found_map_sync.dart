import 'package:flutter/foundation.dart';

/// Notifies reservation map (and similar) to reload lost-item markers after a report.
class LostFoundMapSync {
  LostFoundMapSync._();

  static final List<VoidCallback> _listeners = [];

  static void addListener(VoidCallback listener) => _listeners.add(listener);

  static void removeListener(VoidCallback listener) => _listeners.remove(listener);

  static void notifyChanged() {
    for (final l in List<VoidCallback>.from(_listeners)) {
      l();
    }
  }
}

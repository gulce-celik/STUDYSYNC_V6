import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Android emülatörde fiziksel klavye açıkken bile e-posta alanında IME'nin görünmesini ister.
class KeyboardHost {
  KeyboardHost._();

  static const _channel = MethodChannel('com.example.studysync_mobile/keyboard');

  static Future<void> showSoftIfAndroid() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('showSoftKeyboard');
    } on PlatformException {
      // Yoksay: eski build veya kanal yok
    }
  }
}

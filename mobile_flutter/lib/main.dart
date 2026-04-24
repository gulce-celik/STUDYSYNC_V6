import 'package:flutter/material.dart';

import 'app.dart';
import 'core/auth/auth_controller.dart';
import 'core/auth/auth_scope.dart';

void main() {
  final auth = AuthController();
  runApp(AuthScope(notifier: auth, child: const StudySyncApp()));
}

import 'package:flutter/material.dart';

import 'auth_controller.dart';

class AuthScope extends InheritedNotifier<AuthController> {
  /// [AuthScope] is a widget that provides the [AuthController] to its descendants. It is used to access the [AuthController] from anywhere in the app.
  // constructor
  const AuthScope({
    required AuthController super.notifier, // required because we are using InheritedNotifier and we need to pass the notifier to the child.
    required super.child, // what is super keyword in dart ? it is used to access the parent class.
    super.key, //super parameter is used to pass the key to the parent.
  });

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found');
    return scope!.notifier!;
  }
}

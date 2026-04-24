import 'package:flutter/material.dart';

import 'core/auth/auth_scope.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'shared/widgets/bottom_nav_shell.dart';

class StudySyncApp extends StatelessWidget {
  const StudySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final themeMode = ThemeModeController.instance;

    return ListenableBuilder(
      listenable: themeMode,
      builder: (context, _) {
        return MaterialApp(
          title: 'StudySync',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode.mode,
          home: ListenableBuilder(
            listenable: auth,
            builder: (context, _) {
              return auth.isLoggedIn ? const BottomNavShell() : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}

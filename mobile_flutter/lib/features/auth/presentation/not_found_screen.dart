import 'package:flutter/material.dart';

import '../../../shared/navigation/app_tab_controller.dart';

/// Figma / React `NotFound.tsx` — 404 with back + home.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('404', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
              const SizedBox(height: 12),
              const Text('Page Not Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('The page you\'re looking for doesn\'t exist.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    AppTabController.instance.selectTab(0);
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go Home', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/session/auth_session.dart';
import '../data/admin_data_controller.dart';
import 'admin_admins_screen.dart';
import 'admin_booking_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_students_screen.dart';
import 'widgets/admin_data_source_banner.dart';
import 'widgets/admin_ui.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _pages = [
    AdminDashboardScreen(),
    AdminStudentsScreen(),
    AdminBookingScreen(),
    AdminReportsScreen(),
    AdminAdminsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AdminDataController.instance.refresh();
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('You will return to the student login screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) adminSignOut(context);
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthSession.instance.userName ?? 'Admin';
    return Scaffold(
      backgroundColor: AdminUi.scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AdminUi.heroGradient)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'StudySync Admin',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
            ),
            Text(
              'Signed in as $name',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _confirmSignOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          const AdminDataSourceBanner(),
          Expanded(child: IndexedStack(index: _index, children: _pages)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFFDBEAFE),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.event_available_outlined), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.shield_outlined), label: 'Admins'),
        ],
      ),
    );
  }
}

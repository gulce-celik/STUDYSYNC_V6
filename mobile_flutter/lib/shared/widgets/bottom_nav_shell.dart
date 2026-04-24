import 'package:flutter/material.dart';

import '../navigation/app_tab_controller.dart';
import '../../features/home/presentation/home_screen.dart';// root widgets for the app
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reservation/presentation/reservation_map_screen.dart';
import '../../features/schedule/presentation/weekly_schedule_screen.dart';
import '../../features/study_buddy/presentation/study_buddy_screen.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  static const List<Widget> _pages = [ // five pages for the app
    HomeScreen(),
    ReservationMapScreen(),
    WeeklyScheduleScreen(), // example index 2
    StudyBuddyScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AppTabController.instance.addListener(_onTabChanged);
  }

  @override
  void dispose() { // dispose is used to dispose the widget when the widget is removed from the tree.
    AppTabController.instance.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() => setState(() {}); // setState is used to rebuild the widget when the index changes.

  @override
  Widget build(BuildContext context) {
    final index = AppTabController.instance.currentIndex.clamp(0, _pages.length - 1); // clamp is used to limit the index to the range of 0 to the length of the pages.
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: _pages, // children is used to pass the pages to the IndexedStack.
      ),
      bottomNavigationBar: NavigationBar( // material3 navigation bar
        selectedIndex: index,
        onDestinationSelected: AppTabController.instance.selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Reserve'),
          NavigationDestination(icon: Icon(Icons.calendar_view_week_rounded), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.groups_2_outlined), label: 'Buddy'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

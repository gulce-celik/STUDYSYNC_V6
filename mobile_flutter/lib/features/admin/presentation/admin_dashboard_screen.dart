import 'package:flutter/material.dart';

import '../data/admin_data_controller.dart';
import '../data/admin_mock_data.dart';
import 'admin_student_detail_screen.dart';
import 'widgets/admin_ui.dart';

int _todaySun0() => DateTime.now().weekday % 7;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminDataController.instance,
      builder: (context, _) {
        final snap = AdminDataController.instance.snapshot;
        final today = snap.todayDay;
        final low = snap.lowScoreStudents;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AdminSurfaceCard(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AdminUi.heroGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking pulse',
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${today.dayLabel} • ${today.occupancyPercent}% occupancy',
                              style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _heroChip(Icons.event_available_rounded, '${today.activeReservations} bookings'),
                                const SizedBox(width: 8),
                                _heroChip(Icons.flag_outlined, '${snap.openBuddyReports} reports'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AdminDonutStat(
                        percent: today.occupancyPercent,
                        label: 'Today',
                        onDarkBackground: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const AdminSectionTitle('Weekly occupancy'),
            AdminSurfaceCard(
              child: AdminBarChart(
                values: snap.weeklyOccupancy,
                labels: AdminMockData.dayLabels,
                highlightIndex: _todaySun0(),
              ),
            ),
            const SizedBox(height: 16),
            const AdminSectionTitle('Today at a glance'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                AdminKpiCard(
                  label: 'Registered students',
                  value: '${snap.registeredStudents}',
                  icon: Icons.groups_rounded,
                  color: const Color(0xFF2563EB),
                ),
                AdminKpiCard(
                  label: 'Active reservations (today)',
                  value: '${today.activeReservations}',
                  icon: Icons.event_available_rounded,
                  color: const Color(0xFF9333EA),
                ),
                AdminKpiCard(
                  label: 'Space occupancy',
                  value: '${today.occupancyPercent}%',
                  icon: Icons.pie_chart_outline_rounded,
                  color: const Color(0xFF059669),
                ),
                AdminKpiCard(
                  label: 'Open buddy reports',
                  value: '${snap.openBuddyReports}',
                  icon: Icons.report_outlined,
                  color: const Color(0xFFDC2626),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const AdminSectionTitle('Low responsibility score'),
            if (low.isEmpty)
              const Text('No students below 50% right now.', style: TextStyle(color: Color(0xFF6B7280)))
            else
              ...low.map((s) => _LowScoreTile(student: s)),
          ],
        );
      },
    );
  }

  static Widget _heroChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LowScoreTile extends StatelessWidget {
  const _LowScoreTile({required this.student});

  final AdminStudent student;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AdminSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFF87171)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${student.responsibilityScore}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
            ),
          ),
          title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${student.department} • Score ${student.responsibilityScore}%'),
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => AdminStudentDetailScreen(student: student)),
          ),
        ),
      ),
    );
  }
}

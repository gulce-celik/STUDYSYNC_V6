import 'package:flutter/material.dart';

import '../data/admin_mock_data.dart';
import '../data/admin_moderation_store.dart';
import '../data/admin_reports_repository.dart';
import 'admin_student_detail_screen.dart';
import 'widgets/admin_restrict_sheet.dart';
import 'widgets/admin_restriction_chips.dart';
import 'widgets/admin_ui.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _repo = AdminReportsRepository();

  AdminStudent? _studentFor(String userId) {
    for (final s in AdminMockData.students) {
      if (s.id == userId) return s;
    }
    return null;
  }

  void _openStudent(BuildContext context, String userId) {
    final s = _studentFor(userId);
    if (s == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student record not in admin sample list.')));
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => AdminStudentDetailScreen(student: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminModerationStore.instance,
      builder: (context, _) {
        final reports = _repo.loadReports();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const AdminSectionTitle('Study Buddy — user reports'),
            Text(
              'Only student-on-student reports from Study Buddy (messages, no-show for match, harassment). '
              'Booking no-shows are under the Booking tab.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
            ),
            const SizedBox(height: 12),
            if (reports.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No open user reports.', textAlign: TextAlign.center),
              )
            else
              ...reports.map((r) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AdminSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'User report',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF3730A3)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (r.fromLiveSession)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'This session',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Reported: ${r.reportedName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Reporter: ${r.reporterLabel}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        const SizedBox(height: 8),
                        Text(r.reason, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        if (r.comment.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(r.comment, style: const TextStyle(fontSize: 12, height: 1.35)),
                        ],
                        const SizedBox(height: 8),
                        AdminRestrictionChips(userId: r.reportedUserId),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _openStudent(context, r.reportedUserId),
                                child: const Text('Review profile'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                AdminModerationStore.instance.dismissReport(r.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report dismissed.')));
                              },
                              child: const Text('Dismiss'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () {
                                  AdminModerationStore.instance.warnUser(r.reportedUserId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Warning logged for ${r.reportedName}.')),
                                  );
                                },
                                child: const Text('Warn'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                                onPressed: () => showAdminRestrictSheet(
                                  context: context,
                                  userId: r.reportedUserId,
                                  displayName: r.reportedName,
                                ),
                                child: const Text('Restrict…'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

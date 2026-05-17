import 'package:flutter/material.dart';

import '../data/admin_data_controller.dart';
import '../data/admin_moderation_store.dart';
import 'admin_student_detail_screen.dart';
import 'widgets/admin_restriction_chips.dart';
import 'widgets/admin_ui.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AdminModerationStore.instance,
        AdminDataController.instance,
      ]),
      builder: (context, _) {
        final q = _query.trim().toLowerCase();
        final list = AdminDataController.instance.snapshot.students.where((s) {
          if (q.isEmpty) return true;
          return s.name.toLowerCase().contains(q) ||
              s.email.toLowerCase().contains(q) ||
              s.department.toLowerCase().contains(q);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search name, email, department…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: AdminUi.inputBorder(),
                  enabledBorder: AdminUi.inputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: list.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return const AdminSectionTitle('Registered students');
                  }
                  final s = list[i - 1];
                  final hasRestrictions = AdminModerationStore.instance.isRestricted(s.id);
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
                          gradient: LinearGradient(
                            colors: s.isLowScore
                                ? const [Color(0xFFFCA5A5), Color(0xFFF87171)]
                                : const [Color(0xFF93C5FD), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${s.responsibilityScore}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                          if (hasRestrictions)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Restricted', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C))),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${s.email}\nYear ${s.year} • ${s.activeReservations} active bookings'),
                          if (hasRestrictions) ...[
                            const SizedBox(height: 6),
                            AdminRestrictionChips(userId: s.id),
                          ],
                        ],
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(builder: (_) => AdminStudentDetailScreen(student: s)),
                      ),
                    ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

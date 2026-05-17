import 'package:flutter/material.dart';

import '../data/admin_mock_data.dart';
import '../data/admin_moderation_store.dart';
import 'widgets/admin_restrict_sheet.dart';
import 'widgets/admin_restriction_chips.dart';
import 'widgets/admin_ui.dart';

class AdminStudentDetailScreen extends StatelessWidget {
  const AdminStudentDetailScreen({super.key, required this.student});

  final AdminStudent student;

  Color get _scoreColor {
    if (student.responsibilityScore < 50) return const Color(0xFFDC2626);
    if (student.responsibilityScore < 70) return const Color(0xFFD97706);
    return const Color(0xFF059669);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminModerationStore.instance,
      builder: (context, _) {
        final store = AdminModerationStore.instance;
        final restrictions = store.restrictionsFor(student.id);
        final warned = store.wasWarned(student.id);

        return Scaffold(
          backgroundColor: AdminUi.scaffoldBg,
          appBar: AppBar(
            elevation: 0,
            flexibleSpace: Container(decoration: const BoxDecoration(gradient: AdminUi.heroGradient)),
            title: Text(student.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _ProfileHero(student: student, scoreColor: _scoreColor),
              const SizedBox(height: 16),
              AdminSurfaceCard(
                child: Column(
                  children: [
                    _StatTile(icon: Icons.school_outlined, label: 'Department', value: student.department),
                    const Divider(height: 20),
                    _StatTile(icon: Icons.calendar_today_outlined, label: 'Year', value: 'Year ${student.year}'),
                    const Divider(height: 20),
                    _StatTile(
                      icon: Icons.event_available_outlined,
                      label: 'Active bookings',
                      value: '${student.activeReservations}',
                    ),
                    const Divider(height: 20),
                    _StatTile(
                      icon: Icons.history_rounded,
                      label: 'Total bookings',
                      value: '${student.totalReservations}',
                    ),
                  ],
                ),
              ),
              if (student.needsReview) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDBA74)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_rounded, color: Color(0xFFB45309), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Needs review — low responsibility score or high booking activity.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const AdminSectionTitle('Active restrictions'),
              AdminSurfaceCard(
                child: restrictions.isEmpty
                    ? Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.grey.shade500, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No active restrictions this session.',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          AdminRestrictionChips(userId: student.id),
                          const SizedBox(height: 8),
                          ...restrictions.map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(r.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      store.clearRestriction(student.id, r.kind);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Restriction removed.')),
                                      );
                                    },
                                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFFB91C1C)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              const AdminSectionTitle('Moderation actions'),
              if (warned)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning logged this session.',
                          style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              AdminSurfaceCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: const Color(0xFF1E40AF),
                        ),
                        onPressed: () {
                          store.warnUser(student.id, displayName: student.name);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Warning logged for ${student.name}.')),
                          );
                        },
                        child: const Text('Send warning', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => showAdminRestrictSheet(
                          context: context,
                          userId: student.id,
                          displayName: student.name,
                        ),
                        child: const Text('Apply restriction…', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    if (restrictions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () {
                          store.liftAllRestrictions(student.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('All restrictions lifted for ${student.name}.')),
                          );
                        },
                        child: const Text('Lift all restrictions'),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Buddy pause, booking block, and weekly cap can be applied separately.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.student, required this.scoreColor});

  final AdminStudent student;
  final Color scoreColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AdminUi.heroGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text(student.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text('Score', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                Text(
                  '${student.responsibilityScore}%',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: scoreColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1E40AF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}

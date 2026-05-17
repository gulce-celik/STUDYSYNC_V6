import 'package:flutter/material.dart';

import '../../data/admin_moderation_store.dart';
class AdminRestrictionChips extends StatelessWidget {
  const AdminRestrictionChips({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final list = AdminModerationStore.instance.restrictionsFor(userId);
    if (list.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: list.map((r) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Text(
            r.label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
          ),
        );
      }).toList(),
    );
  }
}

String adminRestrictionSummary(String userId) {
  final list = AdminModerationStore.instance.restrictionsFor(userId);
  if (list.isEmpty) return '';
  return list.map((r) => r.label).join(' • ');
}

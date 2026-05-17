import 'package:flutter/material.dart';

import '../../data/admin_moderation_store.dart';
import '../../domain/admin_restriction.dart';
import 'admin_ui.dart';

/// Lets staff pick what a restriction actually does.
Future<void> showAdminRestrictSheet({
  required BuildContext context,
  required String userId,
  required String displayName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RestrictSheetBody(
      parentContext: context,
      userId: userId,
      displayName: displayName,
    ),
  );
}

class _RestrictSheetBody extends StatefulWidget {
  const _RestrictSheetBody({
    required this.parentContext,
    required this.userId,
    required this.displayName,
  });

  final BuildContext parentContext;
  final String userId;
  final String displayName;

  @override
  State<_RestrictSheetBody> createState() => _RestrictSheetBodyState();
}

class _RestrictSheetBodyState extends State<_RestrictSheetBody> {
  AdminRestrictionKind _kind = AdminRestrictionKind.reservationsBlocked;
  late final TextEditingController _limitCtrl;

  @override
  void initState() {
    super.initState();
    _limitCtrl = TextEditingController(text: '2');
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final limit = int.tryParse(_limitCtrl.text.trim());
    if (_kind == AdminRestrictionKind.reservationWeeklyLimit &&
        (limit == null || limit < 1 || limit > 20)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a weekly limit between 1 and 20.')),
      );
      return;
    }
    AdminModerationStore.instance.applyRestriction(
      userId: widget.userId,
      kind: _kind,
      weeklyLimit: _kind == AdminRestrictionKind.reservationWeeklyLimit ? limit : null,
      displayName: widget.displayName,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(content: Text('Restriction applied for ${widget.displayName}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Restrict ${widget.displayName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose what staff action applies. You can combine multiple restrictions.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
              ),
              const SizedBox(height: 16),
              _option(
                title: 'Pause Study Buddy matching',
                subtitle: 'User cannot be matched or message new buddies.',
                selected: _kind == AdminRestrictionKind.buddyMatchBlocked,
                onTap: () => setState(() => _kind = AdminRestrictionKind.buddyMatchBlocked),
              ),
              _option(
                title: 'Block new reservations',
                subtitle: 'Cannot book desks or group rooms until lifted.',
                selected: _kind == AdminRestrictionKind.reservationsBlocked,
                onTap: () => setState(() => _kind = AdminRestrictionKind.reservationsBlocked),
              ),
              _option(
                title: 'Limit weekly reservations',
                subtitle: 'Cap how many bookings they can make per week.',
                selected: _kind == AdminRestrictionKind.reservationWeeklyLimit,
                onTap: () => setState(() => _kind = AdminRestrictionKind.reservationWeeklyLimit),
              ),
              if (_kind == AdminRestrictionKind.reservationWeeklyLimit) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _limitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max bookings per week',
                    border: AdminUi.inputBorder(),
                    enabledBorder: AdminUi.inputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _apply,
                child: const Text('Apply restriction', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _option({
  required String title,
  required String subtitle,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? const Color(0xFF1E40AF) : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

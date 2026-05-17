import 'package:flutter/material.dart';

import '../../data/admin_workspace_closure_store.dart';
import 'admin_ui.dart';

const _closureReasons = [
  'Broken / damaged',
  'Cleaning / maintenance',
  'Reserved for staff event',
  'Safety issue',
];

Future<void> showAdminWorkspaceClosureSheet({
  required BuildContext context,
  required int dayIndex,
  required String dayLabel,
  required String workspaceId,
}) {
  final store = AdminWorkspaceClosureStore.instance;
  final existing = store.closureFor(dayIndex, workspaceId);

  if (existing != null) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(workspaceId, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'Closed for $dayLabel',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(existing.reason, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                store.reopenWorkspace(dayIndex: dayIndex, workspaceId: workspaceId);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$workspaceId reopened for $dayLabel.')),
                );
              },
              child: const Text('Reopen for bookings', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  var selectedReason = _closureReasons.first;
  final noteCtrl = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModal) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
            child: _SheetContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Close $workspaceId', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(
                    'Students cannot reserve this space on $dayLabel.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  ..._closureReasons.map((r) {
                    final sel = selectedReason == r;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: sel ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => setModal(() => selectedReason = r),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  sel ? Icons.radio_button_checked : Icons.radio_button_off,
                                  size: 20,
                                  color: sel ? const Color(0xFF1E40AF) : const Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(r, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteCtrl,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      border: AdminUi.inputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      final note = noteCtrl.text.trim();
                      final reason = note.isEmpty ? selectedReason : '$selectedReason — $note';
                      store.closeWorkspace(
                        dayIndex: dayIndex,
                        workspaceId: workspaceId,
                        reason: reason,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$workspaceId closed for $dayLabel.')),
                      );
                    },
                    child: const Text('Close for this day', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(noteCtrl.dispose);
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/admin_data_controller.dart';

class AdminDataSourceBanner extends StatelessWidget {
  const AdminDataSourceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminDataController.instance,
      builder: (context, _) {
        final c = AdminDataController.instance;
        final snap = c.snapshot;
        final bg = snap.liveApi && snap.liveFields.isNotEmpty
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7);
        final fg = snap.liveApi && snap.liveFields.isNotEmpty
            ? const Color(0xFF166534)
            : const Color(0xFF92400E);

        return Material(
          color: bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (c.loading)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Expanded(
                  child: Text(
                    snap.sourceLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg, height: 1.3),
                  ),
                ),
                TextButton(
                  onPressed: c.loading ? null : () => c.refresh(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

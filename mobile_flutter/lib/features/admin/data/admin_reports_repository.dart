import '../../../core/demo/buddy_interaction_log.dart';
import 'admin_mock_data.dart';
import 'admin_moderation_store.dart';

class AdminReportsRepository {
  List<AdminBuddyReport> loadReports() {
    final store = AdminModerationStore.instance;
    final merged = <AdminBuddyReport>[];

    var i = 0;
    for (final e in BuddyInteractionLog.entries) {
      final id = 'live-$i';
      i++;
      if (store.isReportDismissed(id)) continue;
      merged.add(
        AdminBuddyReport(
          id: id,
          reportedUserId: e.reportedUserId ?? _resolveUserId(e.buddyName),
          reportedName: e.buddyName,
          reporterLabel: 'Student → student (in-app)',
          reason: e.reportReason,
          comment: e.comment,
          createdAt: e.createdAt,
          fromLiveSession: true,
        ),
      );
    }

    for (final r in AdminMockData.seedReports) {
      if (store.isReportDismissed(r.id)) continue;
      merged.add(r);
    }

    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  static String _resolveUserId(String buddyName) {
    final key = buddyName.toLowerCase();
    for (final s in AdminMockData.students) {
      if (s.name.toLowerCase().contains(key.split(' ').first)) return s.id;
    }
    return 'user-unknown';
  }
}

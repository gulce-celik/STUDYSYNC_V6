/// Session log for Study Buddy "Previous" tab until backend stores reports/comments.
class BuddyInteractionEntry {
  BuddyInteractionEntry({
    required this.buddyName,
    required this.reportReason,
    required this.comment,
    required this.createdAt,
    this.reportedUserId,
  });

  final String buddyName;
  final String? reportedUserId;
  final String reportReason;
  final String comment;
  final DateTime createdAt;
}

class BuddyInteractionLog {
  BuddyInteractionLog._();

  static final List<BuddyInteractionEntry> entries = [];

  static void add({
    required String buddyName,
    required String reportReason,
    String comment = '',
    String? reportedUserId,
  }) {
    entries.insert(
      0,
      BuddyInteractionEntry(
        buddyName: buddyName,
        reportedUserId: reportedUserId,
        reportReason: reportReason,
        comment: comment,
        createdAt: DateTime.now(),
      ),
    );
  }
}

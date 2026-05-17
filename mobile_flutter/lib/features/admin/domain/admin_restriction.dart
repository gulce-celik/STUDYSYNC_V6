/// Staff moderation actions (session-only until admin APIs exist).
enum AdminRestrictionKind {
  buddyMatchBlocked,
  reservationsBlocked,
  reservationWeeklyLimit,
}

class AdminUserRestriction {
  const AdminUserRestriction({
    required this.kind,
    required this.appliedAt,
    this.weeklyLimit,
  });

  final AdminRestrictionKind kind;
  final DateTime appliedAt;
  final int? weeklyLimit;

  String get label => switch (kind) {
        AdminRestrictionKind.buddyMatchBlocked => 'Study Buddy matching off',
        AdminRestrictionKind.reservationsBlocked => 'No new reservations',
        AdminRestrictionKind.reservationWeeklyLimit => 'Weekly booking cap: $weeklyLimit',
      };
}

import 'package:flutter/foundation.dart';

import '../../notifications/data/notifications_controller.dart';
import '../domain/admin_restriction.dart';

/// In-memory moderation actions until admin APIs exist.
class AdminModerationStore extends ChangeNotifier {
  AdminModerationStore._();
  static final AdminModerationStore instance = AdminModerationStore._();

  final Map<String, List<AdminUserRestriction>> _restrictions = {};
  final Set<String> _warnedUserIds = {};
  final Set<String> _dismissedReportIds = {};

  List<AdminUserRestriction> restrictionsFor(String userId) =>
      List.unmodifiable(_restrictions[userId] ?? const []);

  bool hasRestriction(String userId, AdminRestrictionKind kind) =>
      (_restrictions[userId] ?? []).any((r) => r.kind == kind);

  bool isRestricted(String userId) => (_restrictions[userId] ?? []).isNotEmpty;

  int? weeklyReservationLimit(String userId) {
    for (final r in _restrictions[userId] ?? const []) {
      if (r.kind == AdminRestrictionKind.reservationWeeklyLimit) return r.weeklyLimit;
    }
    return null;
  }

  bool wasWarned(String userId) => _warnedUserIds.contains(userId);
  bool isReportDismissed(String reportId) => _dismissedReportIds.contains(reportId);

  void warnUser(String userId, {String? displayName}) {
    _warnedUserIds.add(userId);
    NotificationsController.instance.onAdminWarning(userId: userId, displayName: displayName);
    notifyListeners();
  }

  void applyRestriction({
    required String userId,
    required AdminRestrictionKind kind,
    int? weeklyLimit,
    String? displayName,
  }) {
    final list = _restrictions.putIfAbsent(userId, () => []);
    list.removeWhere((r) => r.kind == kind);
    list.add(
      AdminUserRestriction(
        kind: kind,
        appliedAt: DateTime.now(),
        weeklyLimit: kind == AdminRestrictionKind.reservationWeeklyLimit ? weeklyLimit : null,
      ),
    );
    NotificationsController.instance.onAdminRestriction(
      userId: userId,
      kind: kind,
      weeklyLimit: weeklyLimit,
      displayName: displayName,
    );
    notifyListeners();
  }

  void clearRestriction(String userId, AdminRestrictionKind kind) {
    _restrictions[userId]?.removeWhere((r) => r.kind == kind);
    if (_restrictions[userId]?.isEmpty ?? false) _restrictions.remove(userId);
    notifyListeners();
  }

  void liftAllRestrictions(String userId) {
    _restrictions.remove(userId);
    notifyListeners();
  }

  @Deprecated('Use applyRestriction with a specific kind')
  void restrictUser(String userId) {
    applyRestriction(userId: userId, kind: AdminRestrictionKind.reservationsBlocked);
  }

  void liftRestriction(String userId) => liftAllRestrictions(userId);

  void dismissReport(String reportId) {
    _dismissedReportIds.add(reportId);
    notifyListeners();
  }
}

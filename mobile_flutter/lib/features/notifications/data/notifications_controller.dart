import 'package:flutter/foundation.dart';

import '../../../core/session/auth_session.dart';
import '../../admin/data/admin_mock_data.dart';
import '../../admin/data/admin_moderation_store.dart';
import '../../admin/domain/admin_restriction.dart' show AdminRestrictionKind, AdminUserRestriction;
import '../domain/app_notification.dart';
import 'notifications_api.dart';

/// Session inbox: API when available, otherwise demo + admin moderation sync.
class NotificationsController extends ChangeNotifier {
  NotificationsController._();
  static final NotificationsController instance = NotificationsController._();

  final NotificationsApi _api = NotificationsApi();
  List<AppNotification> _items = [];
  bool _loading = false;
  String? _error;
  bool _usesLiveApi = false;

  List<AppNotification> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  bool get usesLiveApi => _usesLiveApi;

  int get unreadCount => _items.where((n) => !n.read).length;

  void clear() {
    _items = [];
    _error = null;
    _usesLiveApi = false;
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fromApi = await _api.fetchInbox();
      if (fromApi != null) {
        _items = fromApi..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _usesLiveApi = true;
        _mergeModerationForCurrentUser();
      } else {
        _usesLiveApi = false;
        _items = _mockSeed();
        _mergeModerationForCurrentUser();
      }
    } catch (e) {
      _usesLiveApi = false;
      _error = 'Could not load notifications';
      if (_items.isEmpty) _items = _mockSeed();
      _mergeModerationForCurrentUser();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<AppNotification> _mockSeed() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'mock-inv-1',
        type: AppNotificationType.groupInvitation,
        title: 'Group study invitation',
        body: 'Emre invited you to group-3 · 16:00–18:00 on 2026-03-14',
        createdAt: now.subtract(const Duration(hours: 2)),
        relatedId: 'inv-1',
        actionLabel: 'View on Home',
      ),
      AppNotification(
        id: 'mock-rem-1',
        type: AppNotificationType.reservationReminder,
        title: 'Reservation in 30 minutes',
        body: 'desk-5 today 10:00–12:00 — don’t forget QR check-in.',
        createdAt: now.subtract(const Duration(minutes: 40)),
        relatedId: 'res-1',
      ),
    ];
  }

  void _mergeModerationForCurrentUser() {
    final email = AuthSession.instance.userEmail?.trim().toLowerCase();
    if (email == null || email.isEmpty) return;

    AdminStudent? student;
    for (final s in AdminMockData.students) {
      if (s.email.trim().toLowerCase() == email) {
        student = s;
        break;
      }
    }
    if (student == null) return;

    final store = AdminModerationStore.instance;
    if (store.wasWarned(student.id)) {
      _upsert(
        AppNotification(
          id: 'mod-warn-${student.id}',
          type: AppNotificationType.moderationWarning,
          title: 'Campus moderation notice',
          body:
              'An administrator sent you a warning this session. Please follow StudySync booking and buddy rules.',
          createdAt: DateTime.now(),
        ),
      );
    }
    for (final r in store.restrictionsFor(student.id)) {
      _upsert(_restrictionNotification(student, r));
    }
  }

  AppNotification _restrictionNotification(AdminStudent student, AdminUserRestriction r) {
    final label = switch (r.kind) {
      AdminRestrictionKind.buddyMatchBlocked => 'Study buddy matching paused',
      AdminRestrictionKind.reservationsBlocked => 'New reservations blocked',
      AdminRestrictionKind.reservationWeeklyLimit => 'Weekly reservation cap: ${r.weeklyLimit ?? "?"}',
    };
    return AppNotification(
      id: 'mod-rest-${student.id}-${r.kind.name}',
      type: AppNotificationType.moderationRestriction,
      title: 'Account restriction',
      body: '$label — contact campus staff if you have questions.',
      createdAt: r.appliedAt,
    );
  }

  void _upsert(AppNotification n) {
    final i = _items.indexWhere((e) => e.id == n.id);
    if (i >= 0) {
      final prev = _items[i];
      _items[i] = n.copyWith(read: prev.read);
    } else {
      _items.add(n);
    }
    _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markRead(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    if (_items[i].read) return;
    _items[i] = _items[i].copyWith(read: true);
    notifyListeners();
    if (_usesLiveApi) {
      try {
        await _api.markRead(id);
      } catch (_) {}
    }
  }

  Future<void> markAllRead() async {
    _items = _items.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
    if (_usesLiveApi) {
      try {
        await _api.markAllRead();
      } catch (_) {}
    }
  }

  void removeByRelatedId(String relatedId) {
    _items.removeWhere((n) => n.relatedId == relatedId);
    notifyListeners();
  }

  /// Called when admin warns a student (demo bridge until backend events exist).
  void onAdminWarning({required String userId, String? displayName}) {
    _upsert(
      AppNotification(
        id: 'mod-warn-$userId',
        type: AppNotificationType.moderationWarning,
        title: 'Campus moderation notice',
        body: displayName != null
            ? 'Warning recorded for $displayName. Student will see this if they sign in with the matching email.'
            : 'An administrator sent a warning.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void onAdminRestriction({
    required String userId,
    required AdminRestrictionKind kind,
    int? weeklyLimit,
    String? displayName,
  }) {
    final kindLabel = switch (kind) {
      AdminRestrictionKind.buddyMatchBlocked => 'buddy matching paused',
      AdminRestrictionKind.reservationsBlocked => 'reservations blocked',
      AdminRestrictionKind.reservationWeeklyLimit => 'weekly cap set to ${weeklyLimit ?? "?"}',
    };
    _upsert(
      AppNotification(
        id: 'mod-rest-$userId-${kind.name}',
        type: AppNotificationType.moderationRestriction,
        title: 'Account restriction',
        body: displayName != null
            ? '$displayName: $kindLabel'
            : 'Restriction applied: $kindLabel',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}

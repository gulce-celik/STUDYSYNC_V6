import 'package:flutter/foundation.dart';

/// Per-day desk/room closure until admin APIs exist (session-only).
class AdminWorkspaceClosure {
  const AdminWorkspaceClosure({
    required this.workspaceId,
    required this.dayIndex,
    required this.reason,
    required this.closedAt,
  });

  final String workspaceId;
  final int dayIndex;
  final String reason;
  final DateTime closedAt;
}

class AdminWorkspaceClosureStore extends ChangeNotifier {
  AdminWorkspaceClosureStore._();
  static final AdminWorkspaceClosureStore instance = AdminWorkspaceClosureStore._();

  final Map<String, AdminWorkspaceClosure> _closures = {};

  String _key(int dayIndex, String workspaceId) => '$dayIndex|$workspaceId';

  bool isClosed(int dayIndex, String workspaceId) =>
      _closures.containsKey(_key(dayIndex, workspaceId));

  AdminWorkspaceClosure? closureFor(int dayIndex, String workspaceId) =>
      _closures[_key(dayIndex, workspaceId)];

  List<AdminWorkspaceClosure> closuresForDay(int dayIndex) {
    return _closures.values.where((c) => c.dayIndex == dayIndex).toList()
      ..sort((a, b) => a.workspaceId.compareTo(b.workspaceId));
  }

  void closeWorkspace({
    required int dayIndex,
    required String workspaceId,
    required String reason,
  }) {
    _closures[_key(dayIndex, workspaceId)] = AdminWorkspaceClosure(
      workspaceId: workspaceId,
      dayIndex: dayIndex,
      reason: reason,
      closedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void reopenWorkspace({required int dayIndex, required String workspaceId}) {
    _closures.remove(_key(dayIndex, workspaceId));
    notifyListeners();
  }
}

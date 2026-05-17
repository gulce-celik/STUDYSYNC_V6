import 'package:flutter/foundation.dart';

import 'admin_mock_data.dart';
import 'admin_repository.dart';

class AdminDataController extends ChangeNotifier {
  AdminDataController._();
  static final AdminDataController instance = AdminDataController._();

  final AdminRepository _repo = AdminRepository();

  AdminDataSnapshot? _snapshot;
  bool _loading = false;

  AdminDataSnapshot get snapshot {
    if (_snapshot != null) return _snapshot!;
    final t = DateTime.now().weekday % 7;
    return AdminDataSnapshot(
      liveApi: false,
      liveFields: {},
      students: AdminMockData.students,
      todayDay: AdminMockData.campusForDay(t),
      weeklyOccupancy: List<int>.from(AdminMockData.weeklyOccupancyPercent),
      registeredStudents: AdminMockData.totalStudents,
      openBuddyReports: AdminMockData.openBuddyReports,
      workspacesByDateIso: {},
    );
  }

  bool get loading => _loading;
  AdminRepository get repository => _repo;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final todaySun0 = DateTime.now().weekday % 7;
      _snapshot = await _repo.load(todaySun0: todaySun0);
    } catch (e) {
      debugPrint('AdminDataController.refresh: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _snapshot = null;
    notifyListeners();
  }
}

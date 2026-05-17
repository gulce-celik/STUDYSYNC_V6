import 'package:flutter/foundation.dart';

import '../../../core/campus/campus_layout_store.dart';
import '../../../core/session/auth_session.dart';
import '../../reservation/domain/reservation_models.dart';
import 'admin_api.dart';
import 'admin_mock_data.dart';
import 'admin_reports_repository.dart';

/// Whether admin session can call authenticated APIs.
abstract final class AuthSessionHasRealToken {
  static bool get hasRealToken {
    final t = AuthSession.instance.accessToken;
    return t != null && t.isNotEmpty && t != 'admin-local-session';
  }
}

/// What the admin UI is showing and whether it came from the API.
class AdminDataSnapshot {
  const AdminDataSnapshot({
    required this.liveApi,
    required this.liveFields,
    required this.students,
    required this.todayDay,
    required this.weeklyOccupancy,
    required this.registeredStudents,
    required this.openBuddyReports,
    required this.workspacesByDateIso,
    this.lastError,
  });

  final bool liveApi;
  final Set<String> liveFields;
  final List<AdminStudent> students;
  final AdminCampusDaySnapshot todayDay;
  final List<int> weeklyOccupancy;
  final int registeredStudents;
  final int openBuddyReports;
  final Map<String, List<Workspace>> workspacesByDateIso;
  final String? lastError;

  List<AdminStudent> get lowScoreStudents =>
      students.where((s) => s.isLowScore).toList()..sort((a, b) => a.responsibilityScore.compareTo(b.responsibilityScore));

  List<Workspace> workspacesForDateIso(String dateIso) => workspacesByDateIso[dateIso] ?? const [];

  String get sourceLabel {
    if (!liveApi) {
      return 'Sample data — could not reach server (is the backend running?)';
    }
    if (liveFields.isEmpty) {
      return 'Server connected; student list and reports still sample (no admin API yet)';
    }
    final live = liveFields.map(_fieldLabel).join(' + ');
    final mockParts = <String>[];
    if (!liveFields.contains('students')) mockParts.add('student list sample');
    if (!liveFields.contains('reports')) mockParts.add('buddy reports sample');
    if (!liveFields.contains('dashboard')) mockParts.add('KPIs partly sample');
    final mockNote = mockParts.isEmpty ? '' : ' • Mock: ${mockParts.join(', ')}';
    return 'Live: $live$mockNote';
  }

  static String _fieldLabel(String f) => switch (f) {
        'workspaces' => 'desk map',
        'lost-found' => 'lost & found',
        'students' => 'students',
        'dashboard' => 'dashboard',
        'reports' => 'reports',
        _ => f,
      };
}

class AdminRepository {
  AdminRepository({AdminApi? api}) : _api = api ?? AdminApi();

  final AdminApi _api;
  final _reportsRepo = AdminReportsRepository();

  static String dateIsoForDayIndex(int dayIndex) {
    final now = DateTime.now();
    final todaySun0 = now.weekday % 7;
    var diff = dayIndex - todaySun0;
    if (diff < 0) diff += 7;
    final d = now.add(Duration(days: diff));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<AdminDataSnapshot> load({int todaySun0 = 0}) async {
    final liveFields = <String>{};
    var lastError = '';

    List<AdminStudent> students = AdminMockData.students;
    var registeredStudents = AdminMockData.totalStudents;
    try {
      final raw = await _api.fetchAdminStudents();
      if (raw != null && raw.isNotEmpty) {
        students = raw.map(_studentFromJson).toList();
        registeredStudents = students.length;
        liveFields.add('students');
      }
    } catch (e) {
      lastError = e.toString();
      debugPrint('Admin students API: $e');
    }

    final workspacesByDate = <String, List<Workspace>>{};
    var weekly = List<int>.from(AdminMockData.weeklyOccupancyPercent);
    final todayIso = dateIsoForDayIndex(todaySun0);

    for (var d = 0; d < 7; d++) {
      final iso = dateIsoForDayIndex(d);
      try {
        final ws = await _api.fetchWorkspaces(date: iso);
        if (ws != null && ws.isNotEmpty) {
          workspacesByDate[iso] = ws;
          if (d == todaySun0) liveFields.add('workspaces');
          weekly[d] = _occupancyPercent(ws);
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('Admin workspaces $iso: $e');
      }
    }

    final todayWorkspaces = workspacesByDate[todayIso];
    if (todayWorkspaces != null && todayWorkspaces.isNotEmpty) {
      _syncLayoutFromWorkspaces(todayWorkspaces);
    }

    var todayDay = AdminMockData.campusForDay(todaySun0);
    if (todayWorkspaces != null && todayWorkspaces.isNotEmpty) {
      todayDay = _daySnapshotFromWorkspaces(todaySun0, todayWorkspaces);
    }

    try {
      final dash = await _api.fetchAdminDashboard();
      if (dash != null) {
        liveFields.add('dashboard');
        todayDay = AdminCampusDaySnapshot(
          dayIndex: todaySun0,
          dayLabel: AdminMockData.dayLabels[todaySun0],
          occupancyPercent: (dash['occupancyPercent'] as num?)?.toInt() ?? todayDay.occupancyPercent,
          activeReservations: (dash['activeReservations'] as num?)?.toInt() ?? todayDay.activeReservations,
          occupiedDesks: (dash['occupiedDesks'] as num?)?.toInt() ?? todayDay.occupiedDesks,
          occupiedGroups: (dash['occupiedGroups'] as num?)?.toInt() ?? todayDay.occupiedGroups,
        );
        registeredStudents = (dash['registeredStudents'] as num?)?.toInt() ?? registeredStudents;
      }
    } catch (e) {
      debugPrint('Admin dashboard API: $e');
    }

    var openReports = AdminMockData.openBuddyReports;
    try {
      final rep = await _api.fetchAdminBuddyReports();
      if (rep != null) {
        liveFields.add('reports');
        openReports = rep.length;
      }
    } catch (_) {}

    try {
      final lost = await _api.fetchLostItemCount();
      if (lost != null) liveFields.add('lost-found');
    } catch (_) {}

    return AdminDataSnapshot(
      liveApi: AuthSessionHasRealToken.hasRealToken,
      liveFields: liveFields,
      students: students,
      todayDay: todayDay,
      weeklyOccupancy: weekly,
      registeredStudents: registeredStudents,
      openBuddyReports: openReports,
      workspacesByDateIso: workspacesByDate,
      lastError: lastError.isEmpty ? null : lastError,
    );
  }

  List<AdminBuddyReport> loadReports() => _reportsRepo.loadReports();

  AdminCampusDaySnapshot daySnapshot(int dayIndex, AdminDataSnapshot snap) {
    final iso = dateIsoForDayIndex(dayIndex);
    final ws = snap.workspacesForDateIso(iso);
    if (ws.isNotEmpty) return _daySnapshotFromWorkspaces(dayIndex, ws);
    return AdminMockData.campusForDay(dayIndex);
  }

  List<AdminWorkspaceStat> workspaceStatsForDay(AdminCampusDaySnapshot day, List<Workspace> apiWorkspaces) {
    if (apiWorkspaces.isNotEmpty) {
      return apiWorkspaces.map((w) {
        final occ = w.status == 'occupied' ? 88 : 12;
        return AdminWorkspaceStat(
          workspaceId: w.id,
          type: w.type,
          occupancyPercent: occ,
          reservationsToday: w.status == 'occupied' ? 1 : 0,
        );
      }).toList();
    }
    return AdminMockData.workspaceStatsForDay(day);
  }

  static void _syncLayoutFromWorkspaces(List<Workspace> ws) {
    final desks = ws.where((w) => w.type == 'individual').length;
    final groups = ws.where((w) => w.type == 'group').length;
    if (desks > 0 || groups > 0) {
      CampusLayoutStore.instance.applyLayout(
        individualDesks: desks > 0 ? desks : CampusLayoutStore.instance.individualDesks,
        groupRooms: groups,
      );
    }
  }

  static int _occupancyPercent(List<Workspace> ws) {
    if (ws.isEmpty) return 0;
    final occ = ws.where((w) => w.status == 'occupied').length;
    return ((occ * 100) / ws.length).round();
  }

  static AdminCampusDaySnapshot _daySnapshotFromWorkspaces(int dayIndex, List<Workspace> ws) {
    final desks = ws.where((w) => w.type == 'individual').toList();
    final groups = ws.where((w) => w.type == 'group').toList();
    final occupiedDesks = desks.where((w) => w.status == 'occupied').length;
    final occupiedGroups = groups.where((w) => w.status == 'occupied').length;
    final occ = _occupancyPercent(ws);
    return AdminCampusDaySnapshot(
      dayIndex: dayIndex,
      dayLabel: AdminMockData.dayLabels[dayIndex],
      occupancyPercent: occ,
      activeReservations: (occupiedDesks + occupiedGroups * 2 + 8).clamp(4, 200),
      occupiedDesks: occupiedDesks,
      occupiedGroups: occupiedGroups,
    );
  }

  static AdminStudent _studentFromJson(Map<String, dynamic> j) {
    return AdminStudent(
      id: j['id']?.toString() ?? 'user-unknown',
      name: j['name']?.toString() ?? 'Student',
      email: j['email']?.toString() ?? '',
      department: j['department']?.toString() ?? '—',
      year: (j['year'] as num?)?.toInt() ?? 1,
      responsibilityScore: (j['responsibilityScore'] as num?)?.toInt() ?? 70,
      activeReservations: (j['activeReservations'] as num?)?.toInt() ?? 0,
      totalReservations: (j['totalReservations'] as num?)?.toInt() ?? 0,
    );
  }
}

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/session/auth_session.dart';
import '../../reservation/data/reservation_api.dart';
import '../../reservation/domain/reservation_models.dart';
import '../../lost_found/data/lost_found_api.dart';

/// Calls existing `/api/v1` endpoints and probes future `/admin/*` routes.
class AdminApi {
  static const bridgeStudentEmail = 'alice.student@std.yeditepe.edu.tr';
  static const bridgeStudentPassword = 'Password123!';

  bool get _hasToken {
    final t = AuthSession.instance.accessToken;
    return t != null && t.isNotEmpty && t != 'admin-local-session';
  }

  Future<List<Workspace>?> fetchWorkspaces({required String date}) async {
    if (!_hasToken) return null;
    try {
      final api = ReservationApi();
      final individual = await api.getWorkspaces(
        date: date,
        slotId: 'slot-2',
        type: 'individual',
      );
      final group = await api.getWorkspaces(
        date: date,
        slotId: 'slot-2',
        type: 'group',
      );
      final byId = <String, Workspace>{};
      for (final w in [...individual, ...group]) {
        byId[w.id] = w;
      }
      return byId.values.toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<int?> fetchLostItemCount() async {
    if (!_hasToken) return null;
    try {
      final items = await LostFoundApi().getLostItems();
      return items.length;
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchAdminDashboard() async {
    if (!_hasToken) return null;
    try {
      final r = await ApiClient.instance.dio.get<Map<String, dynamic>>('/admin/dashboard');
      return r.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) return null;
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchAdminStudents() async {
    if (!_hasToken) return null;
    try {
      final r = await ApiClient.instance.dio.get<List<dynamic>>('/admin/students');
      return r.data?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) return null;
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchAdminBuddyReports() async {
    if (!_hasToken) return null;
    try {
      final r = await ApiClient.instance.dio.get<List<dynamic>>('/admin/buddy-reports');
      return r.data?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) return null;
      return null;
    }
  }
}

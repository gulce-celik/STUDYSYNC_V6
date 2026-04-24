import 'api_client.dart';

/// GET /api/v1/dashboard/home — `responsibilityScore`, `upcomingReservations`, `quickStats`.
class DashboardApi {
  Future<Map<String, dynamic>> getHome() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>('/dashboard/home');
    return response.data ?? {};
  }
}

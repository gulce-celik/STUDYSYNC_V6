import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_notification.dart';

/// [GET /notifications], [PATCH /notifications/:id/read] — falls back when backend has no route yet.
class NotificationsApi {
  Future<List<AppNotification>?> fetchInbox() async {
    try {
      final response = await ApiClient.instance.dio.get<dynamic>('/notifications');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((n) => n.id.isNotEmpty)
            .toList();
      }
      if (data is Map<String, dynamic>) {
        final items = data['items'] ?? data['notifications'];
        if (items is List) {
          return items
              .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
              .where((n) => n.id.isNotEmpty)
              .toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 501) return null;
      rethrow;
    }
  }

  Future<void> markRead(String id) async {
    try {
      await ApiClient.instance.dio.patch<void>('/notifications/$id/read');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 501) return;
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    try {
      await ApiClient.instance.dio.patch<void>('/notifications/read-all');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 501) return;
      rethrow;
    }
  }
}

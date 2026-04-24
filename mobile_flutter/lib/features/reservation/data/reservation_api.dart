import '../../../core/network/api_client.dart';
import '../domain/reservation_models.dart';

/// `/api/v1/reservations/*` — boş/iskelet backend’de liste boş dönebilir; UI mock’a düşer.
class ReservationApi {
  Future<List<Workspace>> getWorkspaces({
    required String date,
    required String slotId,
    required String type,
  }) async {
    final response = await ApiClient.instance.dio.get(
      '/reservations/workspaces',
      queryParameters: {
        'date': date,
        'slotId': slotId,
        'type': type,
      },
    );

    final data = (response.data as List<dynamic>)
        .map((e) => Workspace.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return data;
  }

  /// POST /reservations
  Future<ReservationDetail> createReservation({
    required String date,
    required String slotId,
    required String workspaceId,
    required String courseCode,
    required String reservationType,
    required bool allowStudyBuddy,
    required List<String> participantNicknames,
  }) async {
    final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/reservations',
      data: {
        'date': date,
        'slotId': slotId,
        'workspaceId': workspaceId,
        'courseCode': courseCode,
        'reservationType': reservationType,
        'allowStudyBuddy': allowStudyBuddy,
        'participantNicknames': participantNicknames,
      },
    );
    final raw = response.data ?? {};
    return ReservationDetail.fromJson(raw);
  }

  /// GET /reservations/me
  Future<List<ReservationDetail>> getMyReservations() async {
    final response = await ApiClient.instance.dio.get<List<dynamic>>('/reservations/me');
    final raw = response.data ?? [];
    return raw.map((e) => ReservationDetail.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// POST /reservations/{id}/cancel — isteğe bağlı zamanlar skor politikası için (api-contract).
  Future<Map<String, dynamic>> cancelReservation(
    String reservationId, {
    DateTime? cancelledAt,
    DateTime? slotStartAt,
  }) async {
    final body = <String, dynamic>{};
    if (cancelledAt != null) body['cancelledAt'] = cancelledAt.toIso8601String();
    if (slotStartAt != null) body['slotStartAt'] = slotStartAt.toIso8601String();
    final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/reservations/$reservationId/cancel',
      data: body.isEmpty ? {} : body,
    );
    return response.data ?? {};
  }
}

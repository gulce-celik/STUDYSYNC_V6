import 'api_client.dart';

/// POST /api/v1/checkin/verify — PDF/Figma: QR ile oturum doğrulama, sorumluluk puanı.
class CheckInApi {
  Future<Map<String, dynamic>> verify({
    required String reservationId,
    required String qrPayload,
  }) async {
    final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/checkin/verify',
      data: {
        'reservationId': reservationId,
        'qrPayload': qrPayload,
      },
    );
    return response.data ?? {};
  }
}

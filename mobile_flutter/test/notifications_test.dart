import 'package:flutter_test/flutter_test.dart';
import 'package:studysync_mobile/features/notifications/domain/app_notification.dart';

void main() {
  test('AppNotification.fromJson parses API shape', () {
    final n = AppNotification.fromJson({
      'id': 'n1',
      'type': 'RESERVATION_REMINDER',
      'title': 'Seat open',
      'body': 'desk-1',
      'createdAt': '2026-05-16T10:00:00Z',
      'read': false,
    });
    expect(n.id, 'n1');
    expect(n.type, AppNotificationType.reservationReminder);
    expect(n.read, false);
  });
}

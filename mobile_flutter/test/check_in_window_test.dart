import 'package:flutter_test/flutter_test.dart';
import 'package:studysync_mobile/features/reservation/domain/reservation_models.dart';
import 'package:studysync_mobile/shared/check_in/check_in_window.dart';

void main() {
  test('isReservationToday matches calendar day', () {
    final today = DateTime.now();
    final iso =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final r = ReservationDetail(
      id: '1',
      workspaceId: 'desk-1',
      date: iso,
      slotId: 'slot-2',
      slotLabel: '09.00-11.00',
      status: 'ACTIVE',
      courseCode: 'CSE344',
      participants: const [],
    );
    expect(CheckInWindow.isReservationToday(r), isTrue);
  });

  test('slotStartLocal maps slot-2 to 09:00', () {
    final r = ReservationDetail(
      id: '1',
      workspaceId: 'desk-1',
      date: '2026-05-16',
      slotId: 'slot-2',
      slotLabel: '09.00-11.00',
      status: 'ACTIVE',
      courseCode: 'CSE344',
      participants: const [],
    );
    final start = CheckInWindow.slotStartLocal(r);
    expect(start, isNotNull);
    expect(start!.hour, 9);
    expect(start.minute, 0);
  });
}

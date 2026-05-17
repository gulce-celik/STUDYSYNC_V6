import '../../features/reservation/domain/reservation_models.dart';

/// Client-side hint for the 15-minute check-in policy (backend enforces date + QR match).
class CheckInWindow {
  CheckInWindow._();

  static const _slotStartHour = <String, int>{
    'slot-1': 6,
    'slot-2': 9,
    'slot-3': 11,
    'slot-4': 13,
    'slot-5': 15,
    'slot-6': 17,
    'slot-7': 20,
    'slot-8': 23,
  };

  static DateTime? reservationDay(String dateIso) {
    final parts = dateIso.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  static DateTime? slotStartLocal(ReservationDetail r) {
    final day = reservationDay(r.date);
    final hour = _slotStartHour[r.slotId];
    if (day == null || hour == null) return null;
    return DateTime(day.year, day.month, day.day, hour);
  }

  /// True when today is the reservation day (matches backend date rule).
  static bool isReservationToday(ReservationDetail r) {
    final day = reservationDay(r.date);
    if (day == null) return false;
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  /// After slot start + [graceMinutes] (product policy: 15).
  static bool isPastGraceWindow(ReservationDetail r, {int graceMinutes = 15}) {
    final start = slotStartLocal(r);
    if (start == null) return false;
    return DateTime.now().isAfter(start.add(Duration(minutes: graceMinutes)));
  }
}

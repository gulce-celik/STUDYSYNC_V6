/// `src/app/data/mockData.ts` — Home / upcoming / davetler.
class HomeMockData {
  HomeMockData._();

  static const responsibilityScore = 92;

  static const List<HomeUpcomingReservation> upcomingReservations = [
    HomeUpcomingReservation(
      id: 'res-1',
      workspaceId: 'desk-5',
      date: '2026-03-10',
      timeSlot: '10:00 - 12:00',
      type: ReservationKind.individual,
    ),
    HomeUpcomingReservation(
      id: 'res-2',
      workspaceId: 'desk-12',
      date: '2026-03-11',
      timeSlot: '14:00 - 16:00',
      type: ReservationKind.individual,
    ),
  ];

  static List<HomeGroupInvitation> initialInvitations() => [
        const HomeGroupInvitation(
          id: 'inv-1',
          workspaceId: 'group-3',
          date: '2026-03-14',
          slot: '16:00 - 18:00',
          createdAt: '2026-03-12T14:00:00',
          expiresAt: '2026-03-12T14:10:00',
        ),
      ];
}

enum ReservationKind { individual, group }

class HomeUpcomingReservation {
  const HomeUpcomingReservation({
    required this.id,
    required this.workspaceId,
    required this.date,
    required this.timeSlot,
    required this.type,
  });

  final String id;
  final String workspaceId;
  final String date;
  final String timeSlot;
  final ReservationKind type;
}

class HomeGroupInvitation {
  const HomeGroupInvitation({
    required this.id,
    required this.workspaceId,
    required this.date,
    required this.slot,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String workspaceId;
  final String date;
  final String slot;
  final String createdAt;
  final String expiresAt;

  /// Dakika cinsinden (demo: createdAt / expiresAt farkı).
  int get expiresInMinutes {
    final c = DateTime.tryParse(createdAt);
    final e = DateTime.tryParse(expiresAt);
    if (c == null || e == null) return 10;
    return e.difference(c).inMinutes.abs().clamp(1, 999);
  }
}

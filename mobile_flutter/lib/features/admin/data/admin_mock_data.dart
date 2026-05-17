import '../../../core/campus/campus_layout_store.dart';

/// Admin console sample data — replace with admin REST APIs when backend ships.
class AdminStudent {
  const AdminStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.year,
    required this.responsibilityScore,
    required this.activeReservations,
    required this.totalReservations,
  });

  final String id;
  final String name;
  final String email;
  final String department;
  final int year;
  final int responsibilityScore;
  final int activeReservations;
  final int totalReservations;

  bool get isLowScore => responsibilityScore < 50;
  bool get needsReview => responsibilityScore < 60 || activeReservations > 4;
}

/// Study Buddy: one student reporting another (not booking/no-show).
class AdminBuddyReport {
  AdminBuddyReport({
    required this.id,
    required this.reportedUserId,
    required this.reportedName,
    required this.reporterLabel,
    required this.reason,
    required this.comment,
    required this.createdAt,
    this.fromLiveSession = false,
  });

  final String id;
  final String reportedUserId;
  final String reportedName;
  final String reporterLabel;
  final String reason;
  final String comment;
  final DateTime createdAt;
  final bool fromLiveSession;
}

class AdminNoShowRecord {
  const AdminNoShowRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.email,
    required this.workspaceId,
    required this.timeSlot,
    required this.dayIndex,
    required this.minutesPastStart,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String email;
  final String workspaceId;
  final String timeSlot;
  final int dayIndex;
  final int minutesPastStart;
}

class AdminWorkspaceStat {
  const AdminWorkspaceStat({
    required this.workspaceId,
    required this.type,
    required this.occupancyPercent,
    required this.reservationsToday,
  });

  final String workspaceId;
  final String type;
  final int occupancyPercent;
  final int reservationsToday;
}

class AdminCampusDaySnapshot {
  const AdminCampusDaySnapshot({
    required this.dayIndex,
    required this.dayLabel,
    required this.occupancyPercent,
    required this.activeReservations,
    required this.occupiedDesks,
    required this.occupiedGroups,
  });

  final int dayIndex;
  final String dayLabel;
  final int occupancyPercent;
  final int activeReservations;
  final int occupiedDesks;
  final int occupiedGroups;
}

abstract final class AdminMockData {
  static const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const totalStudents = 1284;
  static const int openBuddyReports = 7;

  /// Occupancy % per weekday (Sun–Sat) for charts.
  static const List<int> weeklyOccupancyPercent = [38, 55, 62, 71, 68, 74, 48];

  static List<AdminStudent> get students => [
        const AdminStudent(
          id: 'user-alice',
          name: 'Alice Smith',
          email: 'alice.student@std.yeditepe.edu.tr',
          department: 'Computer Engineering',
          year: 3,
          responsibilityScore: 95,
          activeReservations: 2,
          totalReservations: 24,
        ),
        const AdminStudent(
          id: 'user-bob',
          name: 'Bob Jones',
          email: 'bob.student@std.yeditepe.edu.tr',
          department: 'Industrial Engineering',
          year: 2,
          responsibilityScore: 88,
          activeReservations: 1,
          totalReservations: 11,
        ),
        const AdminStudent(
          id: 'user-charlie',
          name: 'Charlie Brown',
          email: 'charlie.student@std.yeditepe.edu.tr',
          department: 'Mathematics',
          year: 4,
          responsibilityScore: 72,
          activeReservations: 3,
          totalReservations: 19,
        ),
        const AdminStudent(
          id: 'user-merve',
          name: 'Merve Yılmaz',
          email: 'merve.student@std.yeditepe.edu.tr',
          department: 'Computer Engineering',
          year: 2,
          responsibilityScore: 42,
          activeReservations: 4,
          totalReservations: 9,
        ),
        const AdminStudent(
          id: 'user-efe',
          name: 'Efe Tan',
          email: 'efe.student@std.yeditepe.edu.tr',
          department: 'Electrical Engineering',
          year: 1,
          responsibilityScore: 38,
          activeReservations: 2,
          totalReservations: 5,
        ),
        const AdminStudent(
          id: 'user-2',
          name: 'Emre Y.',
          email: 'emre.demo@std.yeditepe.edu.tr',
          department: 'Computer Engineering',
          year: 3,
          responsibilityScore: 91,
          activeReservations: 1,
          totalReservations: 15,
        ),
      ];

  static List<AdminStudent> get lowScoreStudents =>
      students.where((s) => s.isLowScore).toList()..sort((a, b) => a.responsibilityScore.compareTo(b.responsibilityScore));

  static AdminCampusDaySnapshot campusForDay(int dayIndex) {
    final i = dayIndex.clamp(0, 6);
    final occ = weeklyOccupancyPercent[i];
    final totalDesks = CampusLayoutStore.instance.individualDesks;
    final totalGroups = CampusLayoutStore.instance.groupRooms;
    final occupiedDesks = ((totalDesks * occ) / 100).round().clamp(0, totalDesks);
    final occupiedGroups = ((totalGroups * occ) / 120).round().clamp(0, totalGroups);
    final activeRes = (occupiedDesks + occupiedGroups * 3 + 20).clamp(12, 120);
    return AdminCampusDaySnapshot(
      dayIndex: i,
      dayLabel: dayLabels[i],
      occupancyPercent: occ,
      activeReservations: activeRes,
      occupiedDesks: occupiedDesks,
      occupiedGroups: occupiedGroups,
    );
  }

  static final List<AdminNoShowRecord> _noShows = [
    const AdminNoShowRecord(
      id: 'ns-1',
      studentId: 'user-efe',
      studentName: 'Efe Tan',
      email: 'efe.student@std.yeditepe.edu.tr',
      workspaceId: 'desk-12',
      timeSlot: '09:00–11:00',
      dayIndex: 0,
      minutesPastStart: 18,
    ),
    const AdminNoShowRecord(
      id: 'ns-2',
      studentId: 'user-merve',
      studentName: 'Merve Yılmaz',
      email: 'merve.student@std.yeditepe.edu.tr',
      workspaceId: 'group-2',
      timeSlot: '13:00–15:00',
      dayIndex: 2,
      minutesPastStart: 22,
    ),
    const AdminNoShowRecord(
      id: 'ns-3',
      studentId: 'user-charlie',
      studentName: 'Charlie Brown',
      email: 'charlie.student@std.yeditepe.edu.tr',
      workspaceId: 'desk-7',
      timeSlot: '10:00–12:00',
      dayIndex: 2,
      minutesPastStart: 16,
    ),
    const AdminNoShowRecord(
      id: 'ns-4',
      studentId: 'user-bob',
      studentName: 'Bob Jones',
      email: 'bob.student@std.yeditepe.edu.tr',
      workspaceId: 'desk-3',
      timeSlot: '14:00–16:00',
      dayIndex: 4,
      minutesPastStart: 20,
    ),
  ];

  static List<AdminNoShowRecord> noShowsForDay(int dayIndex) =>
      _noShows.where((n) => n.dayIndex == dayIndex.clamp(0, 6)).toList();

  static List<AdminBuddyReport> get seedReports => [
        AdminBuddyReport(
          id: 'rep-1',
          reportedUserId: 'user-2',
          reportedName: 'Emre Y.',
          reporterLabel: 'Anonymous student',
          reason: 'Disruptive messages during study match',
          comment: 'Asked for personal contact repeatedly.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AdminBuddyReport(
          id: 'rep-2',
          reportedUserId: 'user-merve',
          reportedName: 'Merve Yılmaz',
          reporterLabel: 'Gülce K.',
          reason: 'No-show for agreed session',
          comment: 'Did not appear at library desk.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AdminBuddyReport(
          id: 'rep-3',
          reportedUserId: 'user-efe',
          reportedName: 'Efe Tan',
          reporterLabel: 'Anonymous student',
          reason: 'Harassment / inappropriate language',
          comment: 'Reported after group study invite.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  static List<AdminWorkspaceStat> workspaceStatsForDay(AdminCampusDaySnapshot day) {
    final layout = CampusLayoutStore.instance;
    return workspaceStatsFromLayout(
      occupiedDesks: day.occupiedDesks,
      totalDesks: layout.individualDesks,
      occupiedGroups: day.occupiedGroups,
      totalGroups: layout.groupRooms,
      occupancySeed: day.occupancyPercent,
    );
  }

  static List<AdminWorkspaceStat> workspaceStatsFromLayout({
    required int occupiedDesks,
    required int totalDesks,
    required int occupiedGroups,
    required int totalGroups,
    int occupancySeed = 62,
  }) {
    final stats = <AdminWorkspaceStat>[];
    for (var i = 1; i <= totalDesks; i++) {
      final occ = i <= occupiedDesks;
      stats.add(AdminWorkspaceStat(
        workspaceId: 'desk-$i',
        type: 'individual',
        occupancyPercent: occ ? 85 + (i % 15) : 8 + (i * 2) % 20,
        reservationsToday: occ ? 1 : 0,
      ));
    }
    for (var g = 1; g <= totalGroups; g++) {
      final occ = g <= occupiedGroups;
      stats.add(AdminWorkspaceStat(
        workspaceId: 'group-$g',
        type: 'group',
        occupancyPercent: occ ? (75 + occupancySeed % 20) : 12,
        reservationsToday: occ ? 2 : 0,
      ));
    }
    return stats;
  }
}

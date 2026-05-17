import '../../../core/campus/campus_layout_store.dart';
import '../../auth/data/registration_mock_data.dart';
import '../domain/reservation_models.dart';

/// Mirrors `src/app/data/mockData.ts` for offline UI parity with the Figma/React prototype.
class ReservationMockData {
  ReservationMockData._();

  static double get mapWidth => CampusLayoutStore.instance.mapWidth;

  static double get mapHeight => CampusLayoutStore.instance.mapHeight;

  static List<String> get instantDeskIds => CampusLayoutStore.instance.instantDeskIds;

  /// Demo/offline — align with [HomeMockData.responsibilityScore] when not using server.
  static const int mockResponsibilityScore = 75;

  static final List<TimeSlot> timeSlots = [
    TimeSlot(id: 'slot-1', label: '06:00 - 09:00 (Morning)'),
    TimeSlot(id: 'slot-2', label: '09:00 - 11:00 (Class Time)'),
    TimeSlot(id: 'slot-3', label: '11:00 - 13:00 (Class Time)'),
    TimeSlot(id: 'slot-4', label: '13:00 - 15:00 (Class Time)'),
    TimeSlot(id: 'slot-5', label: '15:00 - 17:00 (Class Time)'),
    TimeSlot(id: 'slot-6', label: '17:00 - 20:00 (Evening 1)'),
    TimeSlot(id: 'slot-7', label: '20:00 - 23:00 (Evening 2)'),
    TimeSlot(id: 'slot-8', label: '23:00 - 02:00 (Night)'),
  ];

  static final List<CourseOption> courses = RegistrationMockData.courses
      .map((c) => CourseOption(code: c.code, name: c.name))
      .toList();

  /// Map markers come from GET /lost-found (see [ReservationMapScreen]).
  static final List<LostItemRef> lostItems = [];

  static List<Workspace> get workspaces => CampusLayoutStore.instance.workspaces;
}

class TimeSlot {
  const TimeSlot({required this.id, required this.label});
  final String id;
  final String label;
}

class CourseOption {
  const CourseOption({required this.code, required this.name});
  final String code;
  final String name;
}

class LostItemRef {
  const LostItemRef({required this.workspaceId});
  final String workspaceId;
}

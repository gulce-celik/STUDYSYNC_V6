import '../../auth/data/registration_mock_data.dart';
import '../domain/reservation_models.dart';

/// Mirrors `src/app/data/mockData.ts` for offline UI parity with the Figma/React prototype.
class ReservationMockData {
  ReservationMockData._();

  static const double mapWidth = 330;
  static const double mapHeight = 400;

  static const List<String> instantDeskIds = ['desk-2', 'desk-15'];

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

  static final List<LostItemRef> lostItems = [
    LostItemRef(workspaceId: 'desk-8'),
    LostItemRef(workspaceId: 'group-2'),
  ];

  static final List<Workspace> workspaces = _buildWorkspaces();

  static List<Workspace> _buildWorkspaces() {
    final desks = List<Workspace>.generate(24, (i) {
      final occupied = i == 0 || i == 6 || i == 17;
      return Workspace(
        id: 'desk-${i + 1}',
        type: 'individual',
        capacity: 1,
        status: occupied ? 'occupied' : 'available',
        x: 12 + (i % 8) * 40,
        y: 35 + (i ~/ 8) * 65,
      );
    });
    final groups = <Workspace>[
      Workspace(
        id: 'group-1',
        type: 'group',
        capacity: 4,
        status: 'available',
        x: 12,
        y: 265,
      ),
      Workspace(
        id: 'group-2',
        type: 'group',
        capacity: 4,
        status: 'occupied',
        x: 89,
        y: 265,
      ),
      Workspace(
        id: 'group-3',
        type: 'group',
        capacity: 6,
        status: 'available',
        x: 166,
        y: 265,
      ),
      Workspace(
        id: 'group-4',
        type: 'group',
        capacity: 4,
        status: 'available',
        x: 243,
        y: 265,
      ),
    ];
    return [...desks, ...groups];
  }
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

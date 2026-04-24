/// Haftalık program — `src/app/data/mockData.ts` ile uyumlu (StudySync / analiz modülü).
class ScheduleMockData {
  ScheduleMockData._();

  static const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  static const weeklyTimeSlots = [
    '09-10',
    '10-11',
    '11-12',
    '12-13',
    '13-14',
    '14-15',
    '15-16',
    '16-17',
    '17-18',
    '18-19',
    '19-20',
  ];

  static List<ScheduleBlock> initialBlocks() => [
        const ScheduleBlock(day: 'Mon', timeSlot: '09-10', type: ScheduleBlockType.lesson, label: 'CSE-344'),
        const ScheduleBlock(day: 'Mon', timeSlot: '10-11', type: ScheduleBlockType.lesson, label: 'CSE-344'),
        const ScheduleBlock(day: 'Tue', timeSlot: '09-10', type: ScheduleBlockType.lesson, label: 'CSE-323'),
        const ScheduleBlock(day: 'Tue', timeSlot: '10-11', type: ScheduleBlockType.lesson, label: 'CSE-323'),
        const ScheduleBlock(day: 'Tue', timeSlot: '11-12', type: ScheduleBlockType.lesson, label: 'CSE-331'),
        const ScheduleBlock(day: 'Wed', timeSlot: '11-12', type: ScheduleBlockType.lesson, label: 'CSE-348'),
        const ScheduleBlock(day: 'Wed', timeSlot: '12-13', type: ScheduleBlockType.lesson, label: 'CSE-348'),
        const ScheduleBlock(day: 'Thu', timeSlot: '11-12', type: ScheduleBlockType.lesson, label: 'MATH-281'),
        const ScheduleBlock(day: 'Thu', timeSlot: '13-14', type: ScheduleBlockType.lesson, label: 'CSE-354'),
        const ScheduleBlock(day: 'Thu', timeSlot: '14-15', type: ScheduleBlockType.lesson, label: 'CSE-331'),
        const ScheduleBlock(day: 'Thu', timeSlot: '15-16', type: ScheduleBlockType.lesson, label: 'CSE-354'),
        const ScheduleBlock(day: 'Fri', timeSlot: '14-15', type: ScheduleBlockType.lesson, label: 'MTH-302'),
        const ScheduleBlock(day: 'Wed', timeSlot: '16-17', type: ScheduleBlockType.lesson, label: 'TKL-202'),
        const ScheduleBlock(day: 'Thu', timeSlot: '16-17', type: ScheduleBlockType.lesson, label: 'MATH-281'),
      ];
}

enum ScheduleBlockType { lesson, club, busy, exam }

class ScheduleBlock {
  const ScheduleBlock({
    required this.day,
    required this.timeSlot,
    required this.type,
    this.label,
    this.courseCode,
    this.examDate,
  });

  final String day;
  final String timeSlot;
  final ScheduleBlockType type;
  final String? label;
  final String? courseCode;
  final DateTime? examDate;
}

/// Backend `WeeklyScheduleBlockDto` ↔ yerel model.
class ScheduleBlockMapper {
  ScheduleBlockMapper._();

  static String typeToApi(ScheduleBlockType t) {
    switch (t) {
      case ScheduleBlockType.lesson:
        return 'lesson';
      case ScheduleBlockType.club:
        return 'club';
      case ScheduleBlockType.busy:
        return 'busy';
      case ScheduleBlockType.exam:
        return 'busy';
    }
  }

  static ScheduleBlockType? typeFromApi(String? t) {
    switch (t) {
      case 'lesson':
        return ScheduleBlockType.lesson;
      case 'club':
        return ScheduleBlockType.club;
      case 'busy':
        return ScheduleBlockType.busy;
      default:
        return null;
    }
  }

  static ScheduleBlock? fromApi(Map<String, dynamic> m) {
    final type = typeFromApi(m['type']?.toString());
    if (type == null) return null;
    final day = m['day']?.toString() ?? '';
    final slot = m['timeSlot']?.toString() ?? '';
    if (day.isEmpty || slot.isEmpty) return null;
    final label = m['label']?.toString();
    if (label != null && label.startsWith('EXAM:')) {
      final parts = label.split(':');
      if (parts.length >= 3) {
        final code = parts[1].trim();
        final examDate = DateTime.tryParse(parts[2].trim());
        return ScheduleBlock(
          day: day,
          timeSlot: slot,
          type: ScheduleBlockType.exam,
          label: code.isEmpty ? 'Exam' : 'EXAM-$code',
          courseCode: code.isEmpty ? null : code,
          examDate: examDate,
        );
      }
    }
    return ScheduleBlock(day: day, timeSlot: slot, type: type, label: label);
  }

  static Map<String, dynamic> toApi(ScheduleBlock b) {
    final examLabel = (b.type == ScheduleBlockType.exam)
        ? 'EXAM:${b.courseCode ?? ''}:${b.examDate?.toIso8601String() ?? ''}'
        : null;
    return {
      'day': b.day,
      'timeSlot': b.timeSlot,
      'type': typeToApi(b.type),
      if (examLabel != null && examLabel.isNotEmpty) 'label': examLabel,
      if (examLabel == null && b.label != null && b.label!.isNotEmpty) 'label': b.label,
    };
  }
}

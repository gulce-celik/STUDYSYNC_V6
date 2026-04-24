/// `mockStudyBuddies` özeti — GET /study-buddies/suggestions boş dönünce kullanılır.
class StudyBuddyMockRow {
  const StudyBuddyMockRow({
    required this.userId,
    required this.name,
    required this.matchScore,
    required this.commonCourses,
    required this.commonTopics,
  });

  final String userId;
  final String name;
  final int matchScore;
  final List<String> commonCourses;
  final List<String> commonTopics;
}

class StudyBuddyMockData {
  StudyBuddyMockData._();

  static const List<StudyBuddyMockRow> buddies = [
    StudyBuddyMockRow(
      userId: 'user-2',
      name: 'Michael Chen',
      matchScore: 95,
      commonCourses: ['CSE344'],
      commonTopics: ['Software Design', 'UML Diagrams'],
    ),
    StudyBuddyMockRow(
      userId: 'user-3',
      name: 'Emma Williams',
      matchScore: 88,
      commonCourses: ['CSE344', 'CSE331'],
      commonTopics: ['Requirements Analysis', 'SQL'],
    ),
  ];
}

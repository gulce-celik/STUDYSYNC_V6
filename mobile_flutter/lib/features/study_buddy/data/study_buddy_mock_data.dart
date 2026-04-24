/// `mockStudyBuddies` — GET /study-buddies/suggestions boş / offline iken; Smart Filters alanları mock’ta doldurulur.
class StudyBuddyMockRow {
  const StudyBuddyMockRow({
    required this.userId,
    required this.name,
    required this.matchScore,
    required this.commonCourses,
    required this.commonTopics,
    this.gender,
    this.academicYear,
    this.studyStyle,
    this.typicalWeekday,
    this.sessionLengthOfferedMinutes,
    this.studyFocus,
  });

  final String userId;
  final String name;
  final int matchScore;
  final List<String> commonCourses;
  final List<String> commonTopics;

  /// Filtreleme için: Woman / Man / Non-binary; yoksa sunucu satırlarıyla uyum (null = bilinmiyor).
  final String? gender;

  /// Freshman, Sophomore, Junior, Senior
  final String? academicYear;

  /// Silent study, Discussion-based study, Problem solving together
  final String? studyStyle;

  /// Mon … Sun (kısa)
  final String? typicalWeekday;

  /// Bu eşleşmede tipik oturum süresi (dk); filtre: kullanıcının min süresi ile
  final int? sessionLengthOfferedMinutes;

  /// Exam prep, Project work, Weekly reviews — hafif “odak” etiketi
  final String? studyFocus;
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
      gender: 'Man',
      academicYear: 'Junior',
      studyStyle: 'Problem solving together',
      typicalWeekday: 'Tue',
      sessionLengthOfferedMinutes: 120,
      studyFocus: 'Project work',
    ),
    StudyBuddyMockRow(
      userId: 'user-3',
      name: 'Emma Williams',
      matchScore: 88,
      commonCourses: ['CSE344', 'CSE331'],
      commonTopics: ['Requirements Analysis', 'SQL'],
      gender: 'Woman',
      academicYear: 'Senior',
      studyStyle: 'Discussion-based study',
      typicalWeekday: 'Wed',
      sessionLengthOfferedMinutes: 120,
      studyFocus: 'Exam prep',
    ),
    StudyBuddyMockRow(
      userId: 'user-4',
      name: 'Deniz Aydın',
      matchScore: 82,
      commonCourses: ['CSE344', 'CSE211'],
      commonTopics: ['Algorithms', 'Pseudocode'],
      gender: 'Non-binary',
      academicYear: 'Sophomore',
      studyStyle: 'Silent study',
      typicalWeekday: 'Fri',
      sessionLengthOfferedMinutes: 60,
      studyFocus: 'Weekly reviews',
    ),
    StudyBuddyMockRow(
      userId: 'user-5',
      name: 'Sofia Park',
      matchScore: 91,
      commonCourses: ['CSE331', 'CSE312'],
      commonTopics: ['Transactions', 'Processes'],
      gender: 'Woman',
      academicYear: 'Junior',
      studyStyle: 'Problem solving together',
      typicalWeekday: 'Tue',
      sessionLengthOfferedMinutes: 180,
      studyFocus: 'Project work',
    ),
  ];
}

/// Mirrors `mockData.ts` scoreHistory + default course codes for profile display.
library profile_mock_data;

class ProfileScoreEntry {
  const ProfileScoreEntry({
    required this.id,
    required this.date,
    required this.scoreChange,
    required this.description,
  });

  final String id;
  final String date;
  final int scoreChange;
  final String description;
}

abstract final class ProfileMockData {
  static const nickname = 'ahmet_y';

  static const enrolledCourseCodes = ['CSE344', 'CSE331', 'CSE312', 'CSE211'];

  static const scoreHistory = <ProfileScoreEntry>[
    ProfileScoreEntry(id: 'sh-1', date: '2026-03-10', scoreChange: 5, description: '5 successful check-ins completed'),
    ProfileScoreEntry(id: 'sh-2', date: '2026-03-08', scoreChange: 3, description: 'Cancelled reservation 24h in advance'),
    ProfileScoreEntry(id: 'sh-3', date: '2026-03-05', scoreChange: -10, description: 'No-show for reservation'),
    ProfileScoreEntry(id: 'sh-4', date: '2026-03-01', scoreChange: 5, description: '5 successful check-ins completed'),
    ProfileScoreEntry(id: 'sh-5', date: '2026-02-28', scoreChange: 8, description: 'All group members checked in on time'),
  ];
}

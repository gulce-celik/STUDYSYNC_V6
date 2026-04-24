/// Mirrors `src/app/data/mockData.ts` — departments, years, courses for Register / Onboarding.
library registration_mock_data;

class RegistrationDepartment {
  const RegistrationDepartment({required this.id, required this.name});
  final String id;
  final String name;
}

class RegistrationYear {
  const RegistrationYear({required this.id, required this.name});
  final int id;
  final String name;
}

class RegistrationCourse {
  const RegistrationCourse({required this.id, required this.code, required this.name});
  final String id;
  final String code;
  final String name;
}

abstract final class RegistrationMockData {
  /// İskelet liste  ileride backend `GET /reference/departments` ile değiştirilecek.
  static const departments = <RegistrationDepartment>[
    RegistrationDepartment(id: 'cse', name: 'Computer Engineering'),
    RegistrationDepartment(id: 'ie', name: 'Industrial Engineering'),
    RegistrationDepartment(id: 'math', name: 'Mathematics'),
  ];

  static const yearLevels = <RegistrationYear>[
    RegistrationYear(id: 1, name: '1st Year'),
    RegistrationYear(id: 2, name: '2nd Year'),
    RegistrationYear(id: 3, name: '3rd Year'),
    RegistrationYear(id: 4, name: '4th Year'),
  ];

  static const courses = <RegistrationCourse>[
    RegistrationCourse(id: 'cse-344', code: 'CSE344', name: 'Software Engineering'),
    RegistrationCourse(id: 'cse-331', code: 'CSE331', name: 'Database Systems'),
    RegistrationCourse(id: 'cse-312', code: 'CSE312', name: 'Operating Systems'),
    RegistrationCourse(id: 'cse-211', code: 'CSE211', name: 'Data Structures'),
    RegistrationCourse(id: 'math-301', code: 'MATH301', name: 'Linear Algebra'),
    RegistrationCourse(id: 'ie-202', code: 'IE202', name: 'Operations Research'),
  ];
}

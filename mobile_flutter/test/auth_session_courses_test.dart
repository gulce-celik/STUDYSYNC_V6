import 'package:flutter_test/flutter_test.dart';
import 'package:studysync_mobile/core/session/auth_session.dart';

void main() {
  test('AuthSession stores enrolled course codes', () {
    final session = AuthSession.instance;
    session.enrolledCourseCodes = ['CSE344', 'CSE211'];
    expect(session.enrolledCourseCodes, ['CSE344', 'CSE211']);
    session.enrolledCourseCodes = [];
  });
}

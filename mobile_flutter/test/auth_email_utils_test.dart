import 'package:flutter_test/flutter_test.dart';
import 'package:studysync_mobile/features/auth/auth_email_utils.dart';

void main() {
  test('normalize strips trailing dots', () {
    expect(AuthEmailUtils.normalize('a@std.yeditepe.edu.tr.'), 'a@std.yeditepe.edu.tr');
  });

  test('valid Yeditepe email', () {
    expect(AuthEmailUtils.isValidYeditepeEmail('student@std.yeditepe.edu.tr'), isTrue);
    expect(AuthEmailUtils.isValidYeditepeEmail('bad@gmail.com'), isFalse);
  });
}

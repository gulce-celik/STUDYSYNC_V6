import 'package:flutter_test/flutter_test.dart';
import 'package:studysync_mobile/core/admin/admin_allowlist.dart';
import 'package:studysync_mobile/core/admin/admin_email_utils.dart';

void main() {
  test('staff email accepts yeditepe.edu.tr not std', () {
    expect(AdminEmailUtils.isValidStaffEmail('gulce@yeditepe.edu.tr'), isTrue);
    expect(AdminEmailUtils.isValidStaffEmail('alice.student@std.yeditepe.edu.tr'), isFalse);
  });

  test('allowlist verifies demo admin', () {
    expect(AdminAllowlist.isListed('admin@yeditepe.edu.tr'), isTrue);
    expect(AdminAllowlist.verifyPassword('admin@yeditepe.edu.tr', 'Admin123!'), isTrue);
  });
}

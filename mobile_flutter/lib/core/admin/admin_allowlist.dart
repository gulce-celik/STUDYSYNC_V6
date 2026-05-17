import 'admin_roster_store.dart';

/// Staff admin accounts — email must be `@yeditepe.edu.tr` (not `@std.`).
abstract final class AdminAllowlist {
  static bool isListed(String email) => AdminRosterStore.instance.isListed(email);

  static bool verifyPassword(String email, String password) =>
      AdminRosterStore.instance.verifyPassword(email, password);

  static String displayNameFor(String email) => AdminRosterStore.instance.displayNameFor(email);
}

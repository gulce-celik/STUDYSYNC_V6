/// Staff email rules — `@yeditepe.edu.tr` only (no student `@std.` subdomain).
abstract final class AdminEmailUtils {
  static final _staffEmail = RegExp(
    r'^[a-zA-Z0-9._%+-]+@yeditepe\.edu\.tr$',
    caseSensitive: false,
  );

  static String normalize(String raw) {
    var s = raw.trim().toLowerCase();
    while (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static bool isValidStaffEmail(String email) {
    final n = normalize(email);
    if (n.contains('@std.')) return false;
    return _staffEmail.hasMatch(n);
  }
}

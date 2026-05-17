/// Shared Yeditepe email rules for login, register, and password reset.
abstract final class AuthEmailUtils {
  static final yeditepePattern = RegExp(r'^[a-zA-Z0-9._%+-]+@std\.yeditepe\.edu\.tr$');

  static String normalize(String raw) {
    var s = raw.trim();
    while (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static bool isValidYeditepeEmail(String email) => yeditepePattern.hasMatch(email);
}

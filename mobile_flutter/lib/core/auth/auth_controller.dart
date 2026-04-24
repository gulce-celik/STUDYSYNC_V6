import 'package:flutter/foundation.dart';

import '../session/auth_session.dart';

class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false; // _ is used to make the variable private.

  bool get isLoggedIn => _isLoggedIn; // getter is used to get the value of the variable.

  /// Backend [POST /auth/login] başarılı yanıtından sonra çağrılır; token [ApiClient] ile gider.
  void establishSession({ // 
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? user, //user object is coming from the backend.
  }) {
    final session = AuthSession.instance;
    session.accessToken = accessToken;
    session.refreshToken = refreshToken;
    if (user != null) {
      session.userId = user['id']?.toString(); // ? means that the value can be null. 
      session.userName = user['name']?.toString();
      session.userNickname = user['nickname']?.toString();
      session.userEmail = user['email']?.toString();
      session.userDepartment = user['department']?.toString();
      final yearVal = user['year'];
      session.userYear = yearVal is num ? yearVal.toInt() : int.tryParse(yearVal?.toString() ?? '');
    }
    if (!_isLoggedIn) {
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  void logout() {
    AuthSession.instance.clear();
    if (_isLoggedIn) {
      _isLoggedIn = false;
      notifyListeners();
    }
  }
}

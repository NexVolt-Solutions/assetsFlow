import 'package:flutter/foundation.dart';

/// Holds access and refresh tokens. Update on login/refresh; clear on logout.
/// Use [accessToken] for Authorization header; call refresh API when you get 401.
class AuthTokenStore extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }
}

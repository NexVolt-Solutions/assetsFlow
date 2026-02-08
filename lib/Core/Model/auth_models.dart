/// Simple request model for auth API.
class SignupRequest {
  SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String username;
  final String email;
  final String password;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      };
}

/// Login request body.
class LoginRequest {
  LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Refresh token request body.
class RefreshRequest {
  RefreshRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

/// Refresh token response (new access_token, refresh_token, token_type).
class RefreshResponse {
  RefreshResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;

  static RefreshResponse? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final access = json['access_token']?.toString();
    final refresh = json['refresh_token']?.toString();
    if (access == null || access.isEmpty) return null;
    return RefreshResponse(
      accessToken: access,
      refreshToken: refresh ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
    );
  }
}

/// Login success response (access_token, refresh_token, user info).
class LoginResponse {
  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.email,
    required this.username,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final String email;
  final String username;

  static LoginResponse? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final access = json['access_token']?.toString();
    final refresh = json['refresh_token']?.toString();
    if (access == null || access.isEmpty) return null;
    return LoginResponse(
      accessToken: access,
      refreshToken: refresh ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}

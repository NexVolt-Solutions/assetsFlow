import 'dart:convert';
import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/auth_models.dart';
import 'package:asset_flow/Core/Network/network.dart';

/// Auth API: signup, login, refresh, logout.
class AuthRepository {
  AuthRepository({
    BaseApiService? api,
    BaseApiService? authApi,
  })  : _api = api ?? BaseApiService(),
        _authApi = authApi;

  final BaseApiService _api;
  final BaseApiService? _authApi;
  static const String _logTag = 'AuthRepository';

  /// Logout: invalidates token on server. Call before clearing local storage.
  /// Uses authenticated client when available so backend can invalidate access token.
  Future<void> logout() async {
    final client = _authApi ?? _api;
    developer.log('Logout request: POST ${AuthEndpoints.logout}', name: _logTag);
    try {
      final result = await client.post(AuthEndpoints.logout);
      switch (result) {
        case ApiSuccess(:final statusCode, :final body):
          developer.log('Logout response: statusCode=$statusCode body=$body', name: _logTag);
          break;
        case ApiFailure(:final statusCode, :final rawBody, :final message):
          developer.log(
            'Logout error: statusCode=$statusCode message=$message rawBody=$rawBody',
            name: _logTag,
          );
          break;
      }
    } catch (e) {
      developer.log('Logout error: $e', name: _logTag);
    }
  }

  /// Refresh access token. Call when token expires (e.g. on 401).
  /// Returns (true, null, data) on success, (false, message, null) on error.
  Future<({bool success, String? errorMessage, RefreshResponse? data})>
      refresh(String refreshToken) async {
    if (refreshToken.isEmpty) {
      return (success: false, errorMessage: 'Refresh token is missing', data: null);
    }
    final body = RefreshRequest(refreshToken: refreshToken).toJson();
    developer.log(
      'Refresh request: POST ${AuthEndpoints.refresh}',
      name: _logTag,
    );

    final result = await _api.post(AuthEndpoints.refresh, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        developer.log(
          'Refresh response: statusCode=$statusCode body=$body',
          name: _logTag,
        );
        if (statusCode >= 200 &&
            statusCode < 300 &&
            body is Map<String, dynamic>) {
          final data = RefreshResponse.fromJson(body);
          if (data != null) return (success: true, errorMessage: null, data: data);
        }
        return (
          success: false,
          errorMessage: 'Unexpected response: $statusCode',
          data: null,
        );
      case ApiFailure(:final statusCode, :final rawBody, :final message):
        developer.log(
          'Refresh error: statusCode=$statusCode message=$message rawBody=$rawBody',
          name: _logTag,
        );
        final err = _errorFromBackendResponse(rawBody, message);
        return (success: false, errorMessage: err, data: null);
    }
  }

  /// Returns (true, null, response) on success, (false, message, null) on error.
  Future<({bool success, String? errorMessage, LoginResponse? data})> login(
    LoginRequest request,
  ) async {
    final body = request.toJson();
    developer.log(
      'Login request: POST ${AuthEndpoints.login} body=email=${request.email}',
      name: _logTag,
    );

    final result = await _api.post(AuthEndpoints.login, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        developer.log(
          'Login response: statusCode=$statusCode body=$body',
          name: _logTag,
        );
        if (statusCode >= 200 &&
            statusCode < 300 &&
            body is Map<String, dynamic>) {
          final data = LoginResponse.fromJson(body);
          if (data != null)
            return (success: true, errorMessage: null, data: data);
        }
        return (
          success: false,
          errorMessage: 'Unexpected response: $statusCode',
          data: null,
        );
      case ApiFailure(:final statusCode, :final rawBody, :final message):
        developer.log(
          'Login error: statusCode=$statusCode message=$message rawBody=$rawBody',
          name: _logTag,
        );
        final err = _errorFromBackendResponse(rawBody, message);
        return (success: false, errorMessage: err, data: null);
    }
  }

  /// Returns (true, null) on success, (false, message) on error.
  Future<({bool success, String? errorMessage})> signUp(
    SignupRequest request,
  ) async {
    final body = request.toJson();
    developer.log(
      'Signup request: POST ${AuthEndpoints.signup} body=$body',
      name: _logTag,
    );

    final result = await _api.post(AuthEndpoints.signup, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        developer.log(
          'Signup response: statusCode=$statusCode body=$body',
          name: _logTag,
        );
        if (statusCode == 201) return (success: true, errorMessage: null);
        return (
          success: false,
          errorMessage: 'Unexpected response: $statusCode',
        );
      case ApiFailure(:final statusCode, :final rawBody, :final message):
        developer.log(
          'Signup error: statusCode=$statusCode message=$message rawBody=$rawBody',
          name: _logTag,
        );
        final err = _errorFromBackendResponse(rawBody, message);
        return (success: false, errorMessage: err);
    }
  }

  /// Extracts the exact error from backend response body when present.
  /// Falls back to [clientMessage] for network errors (no response body).
  String _errorFromBackendResponse(String? rawBody, String clientMessage) {
    if (rawBody == null || rawBody.isEmpty) return clientMessage;
    try {
      final decoded = jsonDecode(rawBody) as Map<String, dynamic>?;
      if (decoded == null) return rawBody;

      // FastAPI validation: { "detail": [ { "msg": "..." }, ... ] }
      final detail = decoded['detail'];
      if (detail is List && detail.isNotEmpty) {
        final messages = detail
            .whereType<Map>()
            .map((e) => e['msg']?.toString())
            .whereType<String>()
            .toList();
        if (messages.isNotEmpty) return messages.join('\n');
      }
      // Single string: { "detail": "..." }
      if (detail is String) return detail;

      // Common keys: message, error, msg
      final msg = decoded['message'] ?? decoded['error'] ?? decoded['msg'];
      if (msg != null) return msg.toString();
    } catch (_) {}
    return rawBody;
  }
}

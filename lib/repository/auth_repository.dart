import 'dart:convert';
import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/auth_models.dart';
import 'package:asset_flow/Core/Network/network.dart';

/// Auth API: signup. Returns (success, errorMessage).
class AuthRepository {
  AuthRepository({BaseApiService? api}) : _api = api ?? BaseApiService();

  final BaseApiService _api;
  static const String _logTag = 'AuthRepository';

  /// Returns (true, null) on success, (false, message) on error.
  Future<({bool success, String? errorMessage})> signUp(SignupRequest request) async {
    final body = request.toJson();
    developer.log('Signup request: POST ${AuthEndpoints.signup} body=$body', name: _logTag);

    final result = await _api.post(AuthEndpoints.signup, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        developer.log('Signup response: statusCode=$statusCode body=$body', name: _logTag);
        if (statusCode == 201) return (success: true, errorMessage: null);
        return (success: false, errorMessage: 'Unexpected response: $statusCode');
      case ApiFailure(:final statusCode, :final rawBody, :final message):
        developer.log('Signup error: statusCode=$statusCode message=$message rawBody=$rawBody', name: _logTag);
        if (statusCode == 422 && rawBody != null && rawBody.isNotEmpty) {
          final err = _parseValidationError(rawBody);
          return (success: false, errorMessage: err);
        }
        return (success: false, errorMessage: message);
    }
  }

  String _parseValidationError(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody) as Map<String, dynamic>?;
      final detail = decoded?['detail'];
      if (detail is List && detail.isNotEmpty) {
        final messages = detail
            .whereType<Map>()
            .map((e) => e['msg']?.toString())
            .whereType<String>()
            .toList();
        if (messages.isNotEmpty) return messages.join('\n');
      }
    } catch (_) {}
    return rawBody;
  }
}

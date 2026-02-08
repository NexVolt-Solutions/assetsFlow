import 'dart:convert';
import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/profile_model.dart';
import 'package:asset_flow/Core/Network/network.dart';

class ProfileRepository {
  ProfileRepository({required BaseApiService api}) : _api = api;

  final BaseApiService _api;
  static const String _logTag = 'ProfileRepository';

  /// GET current user profile. No parameters.
  Future<({UserProfile? profile, String? errorMessage})> getProfile() async {
    const path = ProfileEndpoints.me;
    developer.log('Get profile request: GET $path', name: _logTag);
    final result = await _api.get(path);

    switch (result) {
      case ApiSuccess(:final body):
        developer.log('Get profile response received', name: _logTag);
        if (body is! Map<String, dynamic>) {
          return (profile: null, errorMessage: 'Invalid response format');
        }
        final profile = UserProfile.fromJson(body);
        if (profile == null) {
          return (profile: null, errorMessage: 'Invalid profile data');
        }
        return (profile: profile, errorMessage: null);
      case ApiFailure(:final message):
        developer.log('Get profile error: message=$message', name: _logTag);
        return (profile: null, errorMessage: message);
    }
  }

  /// PUT update current user profile. Body: full_name, email, username, department, status. Returns updated profile on 200.
  Future<({UserProfile? profile, String? errorMessage})> updateProfile({
    required String fullName,
    required String email,
    required String username,
    required String department,
    required String status,
  }) async {
    const path = ProfileEndpoints.update;
    final body = <String, String>{
      'full_name': fullName,
      'email': email,
      'username': username,
      'department': department,
      'status': status,
    };
    developer.log('Update profile request: PUT $path', name: _logTag);
    final result = await _api.put(path, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        if (statusCode == 200 && body is Map<String, dynamic>) {
          developer.log('Update profile success', name: _logTag);
          final profile = UserProfile.fromJson(body);
          return (profile: profile, errorMessage: null);
        }
        return (profile: null, errorMessage: 'Invalid response format');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Update profile error: statusCode=$statusCode message=$message',
          name: _logTag,
        );
        String errMsg = message;
        if (statusCode == 422 && rawBody != null && rawBody.isNotEmpty) {
          try {
            final map = jsonDecode(rawBody) as Map<String, dynamic>?;
            final detail = map?['detail'];
            if (detail is List && detail.isNotEmpty) {
              final parts = detail
                  .whereType<Map<String, dynamic>>()
                  .map((e) => e['msg']?.toString())
                  .whereType<String>()
                  .toList();
              if (parts.isNotEmpty) errMsg = parts.join(' ');
            }
          } catch (_) {}
        }
        return (profile: null, errorMessage: errMsg);
    }
  }

  /// POST change password. Body: current_password, new_password, confirm_new_password. 200 = success (empty body ok).
  Future<({bool success, String? errorMessage})> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    const path = ProfileEndpoints.changePassword;
    final body = <String, String>{
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_new_password': confirmNewPassword,
    };
    developer.log('Change password request: POST $path', name: _logTag);
    final result = await _api.post(path, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode):
        if (statusCode == 200) {
          developer.log('Change password success', name: _logTag);
          return (success: true, errorMessage: null);
        }
        return (success: false, errorMessage: 'Unexpected status $statusCode');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Change password error: statusCode=$statusCode message=$message',
          name: _logTag,
        );
        String errMsg = message;
        if (statusCode == 422 && rawBody != null && rawBody.isNotEmpty) {
          try {
            final map = jsonDecode(rawBody) as Map<String, dynamic>?;
            final detail = map?['detail'];
            if (detail is List && detail.isNotEmpty) {
              final parts = detail
                  .whereType<Map<String, dynamic>>()
                  .map((e) => e['msg']?.toString())
                  .whereType<String>()
                  .toList();
              if (parts.isNotEmpty) errMsg = parts.join(' ');
            }
          } catch (_) {}
        }
        return (success: false, errorMessage: errMsg);
    }
  }
}

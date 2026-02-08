import 'package:asset_flow/Core/Model/profile_model.dart';
import 'package:asset_flow/repository/profile_repository.dart';
import 'package:flutter/material.dart';

class ProfileManagementScreenViewModel extends ChangeNotifier {
  ProfileManagementScreenViewModel({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  UserProfile? _profile;
  String? _editedFullName;
  String? _editedEmail;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;
  /// Display name (edited value or from API).
  String get displayFullName => _editedFullName ?? _profile?.fullName ?? '';
  /// Display email (edited value or from API).
  String get displayEmail => _editedEmail ?? _profile?.email ?? '';
  bool get isActive => _profile?.isActive ?? true;
  String get username => _profile?.username ?? '';
  String get department => _profile?.department ?? '—';

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getProfile();

    _isLoading = false;
    _profile = result.profile;
    _errorMessage = result.errorMessage;
    _editedFullName = null;
    _editedEmail = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Apply edited name/email locally (no API; persists until next fetch).
  void setEditedProfile({String? fullName, String? email}) {
    if (fullName != null) _editedFullName = fullName;
    if (email != null) _editedEmail = email;
    notifyListeners();
  }

  /// Update profile via API. Uses [fullName] and [email]; username, department, status from current profile. Returns true on success.
  Future<bool> updateProfile({required String fullName, required String email}) async {
    final p = _profile;
    if (p == null) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.updateProfile(
      fullName: fullName,
      email: email,
      username: p.username,
      department: p.department,
      status: p.status,
    );

    _isSaving = false;
    if (result.profile != null) {
      _profile = result.profile;
      _editedFullName = null;
      _editedEmail = null;
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  /// Change password via API. Returns (success, errorMessage).
  Future<({bool success, String? errorMessage})> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final result = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
    if (result.success) {
      _errorMessage = null;
      notifyListeners();
    }
    return (success: result.success, errorMessage: result.errorMessage);
  }
}

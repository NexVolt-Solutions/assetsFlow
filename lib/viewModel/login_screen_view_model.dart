import 'package:asset_flow/Core/Model/auth_models.dart';
import 'package:asset_flow/Core/Model/auth_token_store.dart';
import 'package:asset_flow/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class LoginScreenViewModel extends ChangeNotifier {
  LoginScreenViewModel({
    required AuthRepository repository,
    required AuthTokenStore tokenStore,
  })  : _repository = repository,
        _tokenStore = tokenStore;

  final AuthRepository _repository;
  final AuthTokenStore _tokenStore;

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? validateLogin(String email, String password) {
    final e = email.trim();
    if (e.isEmpty) return 'Email is required';
    if (!e.contains('@') || !e.contains('.')) return 'Enter a valid email';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    final validationError = validateLogin(email, password);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final request = LoginRequest(email: email.trim(), password: password);
    final result = await _repository.login(request);

    _isLoading = false;
    _errorMessage = result.errorMessage;
    if (result.success && result.data != null) {
      _tokenStore.setTokens(result.data!.accessToken, result.data!.refreshToken);
    }
    notifyListeners();
    return result.success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

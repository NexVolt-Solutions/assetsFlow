import 'package:asset_flow/Core/Model/auth_models.dart';
import 'package:asset_flow/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class SignupScreenViewModel extends ChangeNotifier {
  SignupScreenViewModel({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  /// Validates signup inputs. Returns null if valid, else error message.
  String? validateSignup(
    String email,
    String username,
    String password,
    String confirmPassword,
  ) {
    final e = email.trim();
    if (e.isEmpty) return 'Email is required';
    if (!e.contains('@') || !e.contains('.')) return 'Enter a valid email';

    if (username.trim().isEmpty) return 'Username is required';

    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != confirmPassword) return 'Passwords do not match';

    return null;
  }

  Future<bool> signUp(
    String email,
    String username,
    String password,
    String confirmPassword,
  ) async {
    _errorMessage = null;
    final validationError =
        validateSignup(email, username, password, confirmPassword);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final request = SignupRequest(
      username: username.trim(),
      email: email.trim(),
      password: password,
      confirmPassword: confirmPassword,
    );
    final result = await _repository.signUp(request);

    _isLoading = false;
    _errorMessage = result.errorMessage;
    notifyListeners();
    return result.success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

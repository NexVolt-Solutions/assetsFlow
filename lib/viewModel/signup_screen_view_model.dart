import 'package:asset_flow/Core/Model/auth_models.dart';
import 'package:asset_flow/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class SignupScreenViewModel extends ChangeNotifier {
  SignupScreenViewModel({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signUp(String email, String username, String password, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final request = SignupRequest(
      email: email.trim(),
      username: username.trim(),
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

import 'package:asset_flow/Core/Model/dashboard_model.dart';
import 'package:asset_flow/repository/dashboard_repository.dart';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({required DashboardRepository repository})
      : _repository = repository;

  final DashboardRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  DashboardData? _data;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardData? get data => _data;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getDashboard();

    _isLoading = false;
    _data = result.data;
    _errorMessage = result.errorMessage;
    notifyListeners();
  }
}

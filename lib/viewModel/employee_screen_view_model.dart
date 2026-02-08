import 'package:asset_flow/Core/Model/employee_model.dart';
import 'package:asset_flow/repository/employee_repository.dart';
import 'package:flutter/material.dart';

enum EmployeeFilter { all, active, resigned, onHold }

extension EmployeeFilterX on EmployeeFilter {
  String get label {
    switch (this) {
      case EmployeeFilter.all:
        return 'All';
      case EmployeeFilter.active:
        return 'Active';
      case EmployeeFilter.resigned:
        return 'Resigned';
      case EmployeeFilter.onHold:
        return 'On Hold';
    }
  }

  String? get apiStatus {
    switch (this) {
      case EmployeeFilter.all:
        return null;
      case EmployeeFilter.active:
        return 'Active';
      case EmployeeFilter.resigned:
        return 'Resigned';
      case EmployeeFilter.onHold:
        return 'On Hold';
    }
  }
}

class EmployeeScreenViewModel extends ChangeNotifier {
  EmployeeScreenViewModel({required EmployeeRepository repository})
      : _repository = repository;

  final EmployeeRepository _repository;

  bool _isLoading = false;
  bool _isAdding = false;
  String? _errorMessage;
  List<EmployeeItem> _employees = [];
  EmployeeFilter _filter = EmployeeFilter.all;
  int _page = 1;
  static const int _limit = 50;

  EmployeeItem? _detailEmployee;
  String? _detailEmployeeId;
  bool _detailLoading = false;
  String? _detailError;

  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  String? get errorMessage => _errorMessage;
  List<EmployeeItem> get employees => List.unmodifiable(_employees);
  EmployeeFilter get filter => _filter;
  EmployeeItem? get detailEmployee => _detailEmployee;
  String? get detailEmployeeId => _detailEmployeeId;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getEmployees(
      status: _filter.apiStatus,
      page: _page,
      limit: _limit,
    );

    _isLoading = false;
    _employees = result.list;
    _errorMessage = result.errorMessage;
    notifyListeners();
  }

  void setFilter(EmployeeFilter f) {
    if (_filter == f) return;
    _filter = f;
    _page = 1;
    fetchEmployees();
  }

  void addEmployee(EmployeeItem employee) {
    _employees = [employee, ..._employees];
    notifyListeners();
  }

  /// Calls Add Employee API and prepends created employee on success. Returns true on success.
  Future<bool> addEmployeeWithApi(AddEmployeeRequest request) async {
    _isAdding = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.createEmployee(
      username: request.username,
      email: request.email,
      password: request.password,
      department: request.department,
      status: request.status,
      joiningDate: request.joiningDate,
      resignationDate: request.resignationDate,
    );

    _isAdding = false;
    if (result.employee != null) {
      _employees = [result.employee!, ..._employees];
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  void updateEmployee(EmployeeItem old, EmployeeItem updated) {
    _employees = _employees.map((e) => e.id == old.id ? updated : e).toList();
    notifyListeners();
  }

  /// Calls Update Employee API and replaces the employee in list on success. Returns true on success.
  Future<bool> updateEmployeeWithApi(
    String employeeId,
    UpdateEmployeeRequest request,
  ) async {
    final result = await _repository.updateEmployee(
      employeeId: employeeId,
      username: request.username,
      department: request.department,
      status: request.status,
      resignationDate: request.resignationDate,
    );

    if (result.employee != null) {
      final updated = result.employee!;
      EmployeeItem? existing;
      for (final e in _employees) {
        if (e.id == employeeId) {
          existing = e;
          break;
        }
      }
      final merged = existing != null
          ? EmployeeItem(
              id: updated.id,
              name: updated.name,
              initials: updated.initials,
              code: updated.code.isEmpty ? existing.code : updated.code,
              department: updated.department,
              status: updated.status,
              joiningDate: updated.joiningDate,
              resignationDate: updated.resignationDate,
              assignedAssets: updated.assignedAssets.isEmpty
                  ? existing.assignedAssets
                  : updated.assignedAssets,
            )
          : updated;
      _employees = _employees
          .map((e) => e.id == employeeId ? merged : e)
          .toList();
      if (_detailEmployeeId == employeeId) {
        _detailEmployee = merged;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetches full employee detail for the given id (e.g. when expanding a card).
  Future<void> fetchEmployeeDetail(String employeeId) async {
    _detailEmployeeId = employeeId;
    _detailLoading = true;
    _detailError = null;
    _detailEmployee = null;
    notifyListeners();

    final result = await _repository.getEmployeeDetail(employeeId);

    _detailLoading = false;
    _detailEmployee = result.employee;
    _detailError = result.errorMessage;
    notifyListeners();
  }

  /// Clears detail state (e.g. when collapsing the card).
  void clearDetail() {
    _detailEmployee = null;
    _detailEmployeeId = null;
    _detailError = null;
    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/employee_model.dart';
import 'package:asset_flow/Core/Network/network.dart';

class EmployeeRepository {
  EmployeeRepository({required BaseApiService api}) : _api = api;

  final BaseApiService _api;
  static const String _logTag = 'EmployeeRepository';

  /// GET list employees. Optional: status, department, page (default 1), limit (default 10, max 100).
  Future<({List<EmployeeItem> list, String? errorMessage})> getEmployees({
    String? status,
    String? department,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.clamp(1, 100).toString(),
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (department != null && department.isNotEmpty) {
      queryParams['department'] = department;
    }

    developer.log(
      'Employees request: GET ${EmployeeEndpoints.list} query=$queryParams',
      name: _logTag,
    );
    final result = await _api.get(
      EmployeeEndpoints.list,
      queryParameters: queryParams,
    );

    switch (result) {
      case ApiSuccess(:final body):
        developer.log('Employees response: body=$body', name: _logTag);
        List<EmployeeItem> list = [];
        if (body is List) {
          for (final e in body) {
            if (e is Map<String, dynamic>) {
              final item = EmployeeItem.fromJson(e);
              if (item != null) list.add(item);
            }
          }
        } else if (body is Map<String, dynamic>) {
          final results = body['results'] ?? body['data'];
          if (results is List) {
            for (final e in results) {
              if (e is Map<String, dynamic>) {
                final item = EmployeeItem.fromJson(e);
                if (item != null) list.add(item);
              }
            }
          }
        }
        return (list: list, errorMessage: null);
      case ApiFailure(:final message, :final rawBody):
        developer.log(
          'Employees error: message=$message rawBody=$rawBody',
          name: _logTag,
        );
        return (list: <EmployeeItem>[], errorMessage: message);
    }
  }

  /// POST create employee. Returns created employee on 201, or error message on failure/422.
  Future<({EmployeeItem? employee, String? errorMessage})> createEmployee({
    required String username,
    required String email,
    required String password,
    required String department,
    required String status,
    required String joiningDate,
    String? resignationDate,
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      'department': department,
      'status': status,
      'joining_date': joiningDate,
    };
    if (resignationDate != null && resignationDate.isNotEmpty) {
      body['resignation_date'] = resignationDate;
    }
    developer.log(
      'Create employee: POST ${EmployeeEndpoints.list} body keys=${body.keys.toList()}',
      name: _logTag,
    );
    final result = await _api.post(EmployeeEndpoints.list, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        if (statusCode == 201 && body is Map<String, dynamic>) {
          final employee = EmployeeItem.fromJson(body);
          if (employee != null) {
            developer.log('Create employee success: id=${employee.id}', name: _logTag);
            return (employee: employee, errorMessage: null);
          }
        }
        return (employee: null, errorMessage: 'Invalid response from server');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Create employee error: statusCode=$statusCode message=$message',
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
        return (employee: null, errorMessage: errMsg);
    }
  }

  /// GET employee detail by id. Returns full employee with assigned assets.
  Future<({EmployeeItem? employee, String? errorMessage})> getEmployeeDetail(
    String employeeId,
  ) async {
    final path = EmployeeEndpoints.detail(employeeId);
    developer.log('Employee detail: GET $path', name: _logTag);
    final result = await _api.get(path);

    switch (result) {
      case ApiSuccess(:final body):
        if (body is Map<String, dynamic>) {
          final employee = EmployeeItem.fromJson(body);
          if (employee != null) {
            developer.log('Employee detail success: id=${employee.id}', name: _logTag);
            return (employee: employee, errorMessage: null);
          }
        }
        return (employee: null, errorMessage: 'Invalid response from server');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Employee detail error: statusCode=$statusCode message=$message',
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
        return (employee: null, errorMessage: errMsg);
    }
  }

  /// PATCH update employee. Returns updated employee on 200, or error message on failure/422.
  Future<({EmployeeItem? employee, String? errorMessage})> updateEmployee({
    required String employeeId,
    required String username,
    required String department,
    required String status,
    String? resignationDate,
  }) async {
    final path = EmployeeEndpoints.detail(employeeId);
    final body = <String, dynamic>{
      'username': username,
      'department': department,
      'status': status,
    };
    if (resignationDate != null && resignationDate.isNotEmpty) {
      body['resignation_date'] = resignationDate;
    }
    developer.log(
      'Update employee: PATCH $path body keys=${body.keys.toList()}',
      name: _logTag,
    );
    final result = await _api.patch(path, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        if (statusCode == 200 && body is Map<String, dynamic>) {
          final employee = EmployeeItem.fromJson(body);
          if (employee != null) {
            developer.log('Update employee success: id=${employee.id}', name: _logTag);
            return (employee: employee, errorMessage: null);
          }
        }
        return (employee: null, errorMessage: 'Invalid response from server');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Update employee error: statusCode=$statusCode message=$message',
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
        return (employee: null, errorMessage: errMsg);
    }
  }
}

import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/dashboard_model.dart';
import 'package:asset_flow/Core/Network/network.dart';

class DashboardRepository {
  DashboardRepository({required BaseApiService api}) : _api = api;

  final BaseApiService _api;
  static const String _logTag = 'DashboardRepository';

  /// GET dashboard data (stats + recent employees/assets). Requires auth.
  Future<({DashboardData? data, String? errorMessage})> getDashboard() async {
    developer.log('Dashboard request: GET ${DashboardEndpoints.dashboard}', name: _logTag);
    final result = await _api.get(DashboardEndpoints.dashboard);

    switch (result) {
      case ApiSuccess(:final body):
        developer.log('Dashboard response: body=$body', name: _logTag);
        if (body is Map<String, dynamic>) {
          final data = DashboardData.fromJson(body);
          return (data: data, errorMessage: null);
        }
        return (data: null, errorMessage: 'Unexpected response format');
      case ApiFailure(:final message, :final rawBody):
        developer.log('Dashboard error: message=$message rawBody=$rawBody', name: _logTag);
        return (data: null, errorMessage: message);
    }
  }
}

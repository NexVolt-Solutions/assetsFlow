import 'dart:convert';
import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/report_model.dart';
import 'package:asset_flow/Core/Network/network.dart';

class ReportsRepository {
  ReportsRepository({required BaseApiService api}) : _api = api;

  final BaseApiService _api;
  static const String _logTag = 'ReportsRepository';

  /// GET asset history. [period] optional: day, week, month, year (default: month).
  Future<({AssetHistoryResponse? data, String? errorMessage})> getAssetHistory({
    String? period,
  }) async {
    final queryParams = <String, String>{};
    if (period != null && period.isNotEmpty) {
      queryParams['period'] = period;
    }
    const path = ReportsEndpoints.history;
    developer.log('Asset history request: GET $path period=$period', name: _logTag);
    final result = await _api.get(
      path,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    switch (result) {
      case ApiSuccess(:final body):
        developer.log('Asset history response received', name: _logTag);
        if (body is! Map<String, dynamic>) {
          return (data: null, errorMessage: 'Invalid response format');
        }
        final total = _intFrom(body['total']);
        final itemsRaw = body['items'];
        List<AssetHistoryItem> items = [];
        if (itemsRaw is List) {
          for (final e in itemsRaw) {
            if (e is Map<String, dynamic>) {
              final item = AssetHistoryItem.fromJson(e);
              if (item != null) items.add(item);
            }
          }
        }
        return (
          data: AssetHistoryResponse(total: total, items: items),
          errorMessage: null,
        );
      case ApiFailure(:final message, :final rawBody):
        developer.log(
          'Asset history error: message=$message rawBody=$rawBody',
          name: _logTag,
        );
        String errMsg = message;
        if (rawBody != null && rawBody.isNotEmpty) {
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
        return (data: null, errorMessage: errMsg);
    }
  }

  static int _intFrom(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

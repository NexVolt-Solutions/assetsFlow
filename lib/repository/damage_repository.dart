import 'dart:convert';
import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Network/network.dart';

class DamageRepository {
  DamageRepository({required BaseApiService api}) : _api = api;

  final BaseApiService _api;
  static const String _logTag = 'DamageRepository';

  /// GET list all damaged assets. No parameters. Returns total and list of asset items.
  Future<({List<AssetItem> items, int total, String? errorMessage})> getDamagedAssets() async {
    const path = DamageEndpoints.list;
    developer.log('Damaged assets request: GET $path', name: _logTag);
    final result = await _api.get(path);

    switch (result) {
      case ApiSuccess(:final body):
        developer.log('Damaged assets response received', name: _logTag);
        if (body is! Map<String, dynamic>) {
          return (items: <AssetItem>[], total: 0, errorMessage: 'Invalid response format');
        }
        final total = _intFrom(body['total']);
        final itemsRaw = body['items'];
        List<AssetItem> items = [];
        if (itemsRaw is List) {
          for (final e in itemsRaw) {
            if (e is Map<String, dynamic>) {
              final item = AssetItem.fromJson(e);
              if (item != null) items.add(item);
            }
          }
        }
        return (items: items, total: total, errorMessage: null);
      case ApiFailure(:final message, :final rawBody):
        developer.log(
          'Damaged assets error: message=$message rawBody=$rawBody',
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
        return (items: <AssetItem>[], total: 0, errorMessage: errMsg);
    }
  }

  /// POST send damaged asset to repair. Body: asset_id, repair_status, repair_notes, repair_cost, sent_date, completed_date. 201 = success.
  Future<({bool success, String? errorMessage})> sendToRepair(
    String assetId, {
    String repairStatus = 'Pending',
    String repairNotes = '',
    double repairCost = 0,
    required String sentDate,
    String? completedDate,
  }) async {
    final path = DamageEndpoints.sendToRepair(assetId);
    final body = <String, dynamic>{
      'asset_id': assetId,
      'repair_status': repairStatus,
      'repair_notes': repairNotes,
      'repair_cost': repairCost,
      'sent_date': sentDate,
      if (completedDate != null && completedDate.isNotEmpty) 'completed_date': completedDate,
    };
    developer.log('Send to repair request: POST $path', name: _logTag);
    final result = await _api.post(path, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode):
        if (statusCode == 201) {
          developer.log('Send to repair success', name: _logTag);
          return (success: true, errorMessage: null);
        }
        return (success: false, errorMessage: 'Unexpected status $statusCode');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Send to repair error: statusCode=$statusCode message=$message',
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

  /// PUT update repair status (Fixed / Not Repairable / Pending). Body: repair_status, repair_notes, repair_cost, completed_date. 200 = success.
  Future<({bool success, String? errorMessage})> updateRepairStatus(
    String repairId, {
    required String repairStatus,
    String repairNotes = '',
    double repairCost = 0,
    String? completedDate,
  }) async {
    final path = DamageEndpoints.updateRepair(repairId);
    final body = <String, dynamic>{
      'repair_status': repairStatus,
      'repair_notes': repairNotes,
      'repair_cost': repairCost,
      if (completedDate != null && completedDate.isNotEmpty) 'completed_date': completedDate,
    };
    developer.log('Update repair request: PUT $path', name: _logTag);
    final result = await _api.put(path, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode):
        if (statusCode == 200) {
          developer.log('Update repair success', name: _logTag);
          return (success: true, errorMessage: null);
        }
        return (success: false, errorMessage: 'Unexpected status $statusCode');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Update repair error: statusCode=$statusCode message=$message',
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

  /// DELETE remove damaged asset permanently. 200 = success.
  Future<({bool success, String? errorMessage})> removeDamagedAsset(
    String assetId,
  ) async {
    final path = DamageEndpoints.removeDamaged(assetId);
    developer.log('Remove damaged asset request: DELETE $path', name: _logTag);
    final result = await _api.delete(path);

    switch (result) {
      case ApiSuccess(:final statusCode):
        if (statusCode == 200) {
          developer.log('Remove damaged asset success', name: _logTag);
          return (success: true, errorMessage: null);
        }
        return (success: false, errorMessage: 'Unexpected status $statusCode');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Remove damaged asset error: statusCode=$statusCode message=$message',
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

  static int _intFrom(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

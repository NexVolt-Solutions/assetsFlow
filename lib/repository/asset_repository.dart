import 'dart:convert';
import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Network/network.dart';

class AssetRepository {
  AssetRepository({required BaseApiService api}) : _api = api;

  final BaseApiService _api;
  static const String _logTag = 'AssetRepository';
  Future<({List<AssetItem> list, String? errorMessage, bool hasMore})>
  getAssets({
    String? category,
    String? currentStatus,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.clamp(1, 100).toString(),
    };
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (currentStatus != null && currentStatus.isNotEmpty) {
      queryParams['current_status'] = currentStatus;
    }

    developer.log(
      'Assets request: GET ${AssetEndpoints.list} query=$queryParams',
      name: _logTag,
    );
    final result = await _api.get(
      AssetEndpoints.list,
      queryParameters: queryParams,
    );

    switch (result) {
      case ApiSuccess(:final body):
        developer.log('Assets response: body=$body', name: _logTag);
        List<AssetItem> list = [];
        bool hasMore = false;
        if (body is List) {
          for (final e in body) {
            if (e is Map<String, dynamic>) {
              final item = AssetItem.fromJson(e);
              if (item != null) list.add(item);
            }
          }
          hasMore = list.length >= limit;
        } else if (body is Map<String, dynamic>) {
          final results = body['results'] ?? body['data'];
          if (results is List) {
            for (final e in results) {
              if (e is Map<String, dynamic>) {
                final item = AssetItem.fromJson(e);
                if (item != null) list.add(item);
              }
            }
            hasMore = body['next'] != null || results.length >= limit;
          }
        }
        return (list: list, errorMessage: null, hasMore: hasMore);
      case ApiFailure(:final message, :final rawBody):
        developer.log(
          'Assets error: message=$message rawBody=$rawBody',
          name: _logTag,
        );
        String errMsg = message;
        try {
          if (rawBody != null && rawBody.isNotEmpty) {
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
          }
        } catch (_) {}
        return (list: <AssetItem>[], errorMessage: errMsg, hasMore: false);
    }
  }

  /// POST create asset. Returns created asset on 201, or error message on failure/422.
  Future<({AssetItem? asset, String? errorMessage})> createAsset(
    AddAssetRequest request,
  ) async {
    final body = <String, dynamic>{
      'asset_code': request.assetCode,
      'name': request.name,
      'category': request.category,
      'brand': request.brand,
      'model': request.model,
      'version': request.version,
      'condition': request.condition,
      'current_status': request.currentStatus,
    };
    developer.log(
      'Create asset: POST ${AssetEndpoints.list} body keys=${body.keys.toList()}',
      name: _logTag,
    );
    final result = await _api.post(AssetEndpoints.list, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        if (statusCode == 201 && body is Map<String, dynamic>) {
          final asset = AssetItem.fromJson(body);
          if (asset != null) {
            developer.log('Create asset success: id=${asset.id}', name: _logTag);
            return (asset: asset, errorMessage: null);
          }
        }
        return (asset: null, errorMessage: 'Invalid response from server');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Create asset error: statusCode=$statusCode message=$message',
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
        return (asset: null, errorMessage: errMsg);
    }
  }

  /// PATCH update asset. Returns updated asset on 200, or error message on failure/422.
  Future<({AssetItem? asset, String? errorMessage})> updateAsset({
    required String assetId,
    required UpdateAssetRequest request,
  }) async {
    final path = AssetEndpoints.detail(assetId);
    final body = <String, dynamic>{
      'name': request.name,
      'category': request.category,
      'brand': request.brand,
      'model': request.model,
      'version': request.version,
      'condition': request.condition,
    };
    if (request.currentStatus != null && request.currentStatus!.isNotEmpty) {
      body['current_status'] = request.currentStatus!;
    }
    developer.log(
      'Update asset: PATCH $path body keys=${body.keys.toList()}',
      name: _logTag,
    );
    final result = await _api.patch(path, body: body);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        if (statusCode == 200 && body is Map<String, dynamic>) {
          final asset = AssetItem.fromJson(body);
          if (asset != null) {
            developer.log('Update asset success: id=${asset.id}', name: _logTag);
            return (asset: asset, errorMessage: null);
          }
        }
        return (asset: null, errorMessage: 'Invalid response from server');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Update asset error: statusCode=$statusCode message=$message',
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
        return (asset: null, errorMessage: errMsg);
    }
  }

  /// DELETE asset by id. Returns success or error message.
  Future<({bool success, String? errorMessage})> deleteAsset(String assetId) async {
    final path = AssetEndpoints.detail(assetId);
    developer.log('Delete asset: DELETE $path', name: _logTag);
    final result = await _api.delete(path);

    switch (result) {
      case ApiSuccess(:final statusCode):
        if (statusCode == 200) {
          developer.log('Delete asset success: id=$assetId', name: _logTag);
          return (success: true, errorMessage: null);
        }
        return (success: false, errorMessage: 'Request failed with status $statusCode');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Delete asset error: statusCode=$statusCode message=$message',
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

  /// POST assign multiple assets to an employee. Body: list of asset ids. Returns success or error message.
  Future<({bool success, String? errorMessage})> assignAssetsToEmployee({
    required String employeeId,
    required List<String> assetIds,
    String? notes,
  }) async {
    final queryParams = <String, String>{'employee_id': employeeId};
    if (notes != null && notes.isNotEmpty) queryParams['notes'] = notes;
    developer.log(
      'Assign assets: POST ${AssetEndpoints.assign} employee_id=$employeeId assetIds=$assetIds',
      name: _logTag,
    );
    final result = await _api.post(
      AssetEndpoints.assign,
      body: assetIds,
      queryParameters: queryParams,
    );

    switch (result) {
      case ApiSuccess(:final statusCode):
        if (statusCode == 200) {
          developer.log('Assign assets success', name: _logTag);
          return (success: true, errorMessage: null);
        }
        return (success: false, errorMessage: 'Request failed with status $statusCode');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Assign assets error: statusCode=$statusCode message=$message',
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

  /// POST return asset to store. Returns updated asset on 200, or error message.
  Future<({AssetItem? asset, String? errorMessage})> returnAssetToStore(
    String assetId, {
    String? notes,
  }) async {
    final path = AssetEndpoints.returnToStore(assetId);
    final queryParams = <String, String>{};
    if (notes != null && notes.isNotEmpty) queryParams['notes'] = notes;
    developer.log('Return asset to store: POST $path', name: _logTag);
    final result = await _api.post(
      path,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        if (statusCode == 200 && body is Map<String, dynamic>) {
          final asset = AssetItem.fromJson(body);
          if (asset != null) {
            developer.log('Return asset success: id=${asset.id}', name: _logTag);
            return (asset: asset, errorMessage: null);
          }
        }
        return (asset: null, errorMessage: 'Invalid response from server');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Return asset error: statusCode=$statusCode message=$message',
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
        return (asset: null, errorMessage: errMsg);
    }
  }

  /// POST report damaged asset. Query: employee_id, reason, damage_date (required). Returns updated asset on 200.
  Future<({AssetItem? asset, String? errorMessage})> reportDamage(
    String assetId, {
    required String employeeId,
    required String reason,
    required String damageDate,
  }) async {
    final path = AssetEndpoints.reportDamage(assetId);
    final queryParams = <String, String>{
      'employee_id': employeeId,
      'reason': reason,
      'damage_date': damageDate,
    };
    developer.log('Report damage: POST $path', name: _logTag);
    final result = await _api.post(
      path,
      queryParameters: queryParams,
    );

    switch (result) {
      case ApiSuccess(:final statusCode, :final body):
        if (statusCode == 200 && body is Map<String, dynamic>) {
          final asset = AssetItem.fromJson(body);
          if (asset != null) {
            developer.log('Report damage success: id=${asset.id}', name: _logTag);
            return (asset: asset, errorMessage: null);
          }
        }
        return (asset: null, errorMessage: 'Invalid response from server');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Report damage error: statusCode=$statusCode message=$message',
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
        return (asset: null, errorMessage: errMsg);
    }
  }

  /// POST bulk import assets from CSV/Excel file. Returns success message on 200, error on failure.
  Future<({bool success, String? message, String? errorMessage})> importAssets({
    required List<int> fileBytes,
    required String filename,
  }) async {
    const path = AssetEndpoints.import;
    developer.log('Import assets: POST $path filename=$filename', name: _logTag);
    final result = await _api.postMultipart(
      path,
      fileField: 'file',
      fileBytes: fileBytes,
      filename: filename,
    );

    switch (result) {
      case ApiSuccess(:final statusCode, :final body, :final rawBody):
        if (statusCode == 200) {
          developer.log('Import assets success', name: _logTag);
          final message = body is String
              ? body
              : rawBody != null && rawBody.isNotEmpty
                  ? rawBody
                  : 'Import completed';
          return (success: true, message: message, errorMessage: null);
        }
        return (success: false, message: null, errorMessage: 'Unexpected status $statusCode');
      case ApiFailure(:final message, :final statusCode, :final rawBody):
        developer.log(
          'Import assets error: statusCode=$statusCode message=$message',
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
        return (success: false, message: null, errorMessage: errMsg);
    }
  }

  /// GET export all assets to CSV. Returns CSV string on 200.
  Future<({bool success, String? csvContent, String? errorMessage})> exportAssets() async {
    const path = AssetEndpoints.export;
    developer.log('Export assets: GET $path', name: _logTag);
    final result = await _api.get(path);

    switch (result) {
      case ApiSuccess(:final statusCode, :final body, :final rawBody):
        if (statusCode == 200) {
          developer.log('Export assets success', name: _logTag);
          final csvContent = body is String
              ? body
              : (rawBody != null && rawBody.isNotEmpty ? rawBody : '');
          return (success: true, csvContent: csvContent, errorMessage: null);
        }
        return (success: false, csvContent: null, errorMessage: 'Unexpected status $statusCode');
      case ApiFailure(:final message, :final statusCode):
        developer.log(
          'Export assets error: statusCode=$statusCode message=$message',
          name: _logTag,
        );
        return (success: false, csvContent: null, errorMessage: message);
    }
  }
}

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Network/network.dart';

class StoreRepository {
  StoreRepository({required BaseApiService api}) : _api = api;

  final BaseApiService _api;
  static const String _logTag = 'StoreRepository';

  /// GET list all assets currently in Store / Inventory. No parameters. Returns array of asset objects.
  Future<({List<AssetItem> list, String? errorMessage})> getStoreAssets() async {
    const path = StoreEndpoints.list;
    developer.log('Store assets request: GET $path', name: _logTag);
    final result = await _api.get(path);

    switch (result) {
      case ApiSuccess(:final body):
        developer.log('Store assets response received', name: _logTag);
        List<AssetItem> list = [];
        if (body is List) {
          for (final e in body) {
            if (e is Map<String, dynamic>) {
              final item = AssetItem.fromJson(e);
              if (item != null) list.add(item);
            }
          }
        } else if (body is Map<String, dynamic>) {
          final results = body['results'] ?? body['data'];
          if (results is List) {
            for (final e in results) {
              if (e is Map<String, dynamic>) {
                final item = AssetItem.fromJson(e);
                if (item != null) list.add(item);
              }
            }
          }
        }
        return (list: list, errorMessage: null);
      case ApiFailure(:final message, :final rawBody):
        developer.log(
          'Store assets error: message=$message rawBody=$rawBody',
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
        return (list: <AssetItem>[], errorMessage: errMsg);
    }
  }
}

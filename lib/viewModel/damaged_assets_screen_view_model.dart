import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/repository/damage_repository.dart';
import 'package:flutter/material.dart';

class DamagedAssetsScreenViewModel extends ChangeNotifier {
  DamagedAssetsScreenViewModel({required DamageRepository repository})
      : _repository = repository;

  final DamageRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AssetItem> _items = [];
  int _total = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AssetItem> get items => List.unmodifiable(_items);
  int get total => _total;

  Future<void> fetchDamagedAssets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getDamagedAssets();

    _isLoading = false;
    _items = result.items;
    _total = result.total;
    _errorMessage = result.errorMessage;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Remove asset from list locally (no API). Effect until next fetch.
  void removeAssetLocally(String assetId) {
    _items = _items.where((a) => a.id != assetId).toList();
    notifyListeners();
  }

  /// Remove damaged asset permanently via API. On success removes from list. Returns true on success.
  Future<bool> removeDamagedAsset(String assetId) async {
    final result = await _repository.removeDamagedAsset(assetId);
    if (result.success) {
      removeAssetLocally(assetId);
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  /// Send damaged asset to repair via API. On success removes from list. Returns true on success.
  Future<bool> sendToRepair(
    String assetId, {
    String? repairNotes,
    double? repairCost,
  }) async {
    final now = DateTime.now();
    final sentDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final result = await _repository.sendToRepair(
      assetId,
      repairNotes: repairNotes ?? '',
      repairCost: repairCost ?? 0,
      sentDate: sentDate,
    );
    if (result.success) {
      removeAssetLocally(assetId);
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }
}

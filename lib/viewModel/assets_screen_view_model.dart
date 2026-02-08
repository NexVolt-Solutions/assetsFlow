import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/repository/asset_repository.dart';
import 'package:flutter/material.dart';

enum AssetCategory { all, laptop, mouse, keyboard, monitor, mobile, headset }

extension AssetCategoryX on AssetCategory {
  String get label {
    switch (this) {
      case AssetCategory.all:
        return 'All';
      case AssetCategory.laptop:
        return 'Laptop';
      case AssetCategory.mouse:
        return 'Mouse';
      case AssetCategory.keyboard:
        return 'Keyboard';
      case AssetCategory.monitor:
        return 'Monitor';
      case AssetCategory.mobile:
        return 'Mobile';
      case AssetCategory.headset:
        return 'Headset';
    }
  }
}

enum AssetStatusFilter { all, inUse, store, damaged, underRepair }

extension AssetStatusFilterX on AssetStatusFilter {
  String get label {
    switch (this) {
      case AssetStatusFilter.all:
        return 'All';
      case AssetStatusFilter.inUse:
        return 'In Use';
      case AssetStatusFilter.store:
        return 'Store';
      case AssetStatusFilter.damaged:
        return 'Damaged';
      case AssetStatusFilter.underRepair:
        return 'Under Repair';
    }
  }

  String? get statusValue {
    switch (this) {
      case AssetStatusFilter.all:
        return null;
      case AssetStatusFilter.inUse:
        return 'In Use';
      case AssetStatusFilter.store:
        return 'In Store';
      case AssetStatusFilter.damaged:
        return 'Damaged';
      case AssetStatusFilter.underRepair:
        return 'Under Repair';
    }
  }
}

class AssetsScreenViewModel extends ChangeNotifier {
  AssetsScreenViewModel({required AssetRepository repository})
      : _repository = repository;

  final AssetRepository _repository;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isImporting = false;
  bool _isExporting = false;
  String? _errorMessage;
  List<AssetItem> _assets = [];
  AssetCategory _category = AssetCategory.all;
  AssetStatusFilter _statusFilter = AssetStatusFilter.all;
  int _page = 1;
  bool _hasMore = true;
  static const int _limit = 20;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isImporting => _isImporting;
  bool get isExporting => _isExporting;
  String? get errorMessage => _errorMessage;
  List<AssetItem> get assets => List.unmodifiable(_assets);
  AssetCategory get category => _category;
  AssetStatusFilter get statusFilter => _statusFilter;
  bool get hasMore => _hasMore;

  Future<void> fetchAssets() async {
    _page = 1;
    _isLoading = true;
    _errorMessage = null;
    _hasMore = true;
    notifyListeners();

    final result = await _repository.getAssets(
      category: _category == AssetCategory.all ? null : _category.label,
      currentStatus: _statusFilter.statusValue,
      page: _page,
      limit: _limit,
    );

    _isLoading = false;
    _assets = result.list;
    _errorMessage = result.errorMessage;
    _hasMore = result.hasMore;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _assets.isEmpty) return;
    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final result = await _repository.getAssets(
      category: _category == AssetCategory.all ? null : _category.label,
      currentStatus: _statusFilter.statusValue,
      page: nextPage,
      limit: _limit,
    );

    _isLoadingMore = false;
    if (result.list.isNotEmpty) {
      _page = nextPage;
      _assets = [..._assets, ...result.list];
    }
    _hasMore = result.hasMore;
    _errorMessage = result.errorMessage;
    notifyListeners();
  }

  void setCategory(AssetCategory c) {
    if (_category == c) return;
    _category = c;
    fetchAssets();
  }

  void setStatusFilter(AssetStatusFilter s) {
    if (_statusFilter == s) return;
    _statusFilter = s;
    fetchAssets();
  }

  void addAsset(AssetItem asset) {
    _assets = [asset, ..._assets];
    notifyListeners();
  }

  /// Calls Add Asset API and prepends created asset on success. Returns true on success.
  Future<bool> addAssetWithApi(AddAssetRequest request) async {
    final result = await _repository.createAsset(request);

    if (result.asset != null) {
      _assets = [result.asset!, ..._assets];
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  void updateAsset(AssetItem old, AssetItem updated) {
    _assets = _assets.map((a) => a.id == old.id ? updated : a).toList();
    notifyListeners();
  }

  /// Calls Edit Asset API and replaces the asset in list on success. Returns true on success.
  Future<bool> updateAssetWithApi(String assetId, UpdateAssetRequest request) async {
    final result = await _repository.updateAsset(assetId: assetId, request: request);

    if (result.asset != null) {
      final updated = result.asset!;
      AssetItem? existing;
      for (final a in _assets) {
        if (a.id == assetId) {
          existing = a;
          break;
        }
      }
      final merged = existing != null
          ? AssetItem(
              id: updated.id,
              name: updated.name,
              assetId: updated.assetId.isEmpty ? existing.assetId : updated.assetId,
              category: updated.category,
              status: updated.status,
              brand: updated.brand,
              model: updated.model,
              condition: updated.condition,
              assignedTo: updated.assignedTo,
              lastReturnedBy: updated.lastReturnedBy,
            )
          : updated;
      _assets = _assets.map((a) => a.id == assetId ? merged : a).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  void removeAsset(AssetItem asset) {
    _assets = _assets.where((a) => a.id != asset.id).toList();
    notifyListeners();
  }

  /// Calls Delete Asset API and removes the asset from list on success. Returns true on success.
  Future<bool> deleteAssetWithApi(String assetId) async {
    final result = await _repository.deleteAsset(assetId);

    if (result.success) {
      _assets = _assets.where((a) => a.id != assetId).toList();
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

  /// Returns an asset to store. On success replaces the asset in the list. Returns true on success.
  Future<bool> returnAssetToStore(String assetId, {String? notes}) async {
    final result = await _repository.returnAssetToStore(assetId, notes: notes);
    if (result.asset != null) {
      final updated = result.asset!;
      _assets = _assets.map((a) => a.id == assetId ? updated : a).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  /// Reports an asset as damaged. On success replaces the asset in the list. Returns true on success.
  Future<bool> reportDamage({
    required String assetId,
    required String employeeId,
    required String reason,
    required String damageDate,
  }) async {
    final result = await _repository.reportDamage(
      assetId,
      employeeId: employeeId,
      reason: reason,
      damageDate: damageDate,
    );
    if (result.asset != null) {
      final updated = result.asset!;
      _assets = _assets.map((a) => a.id == assetId ? updated : a).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  /// Export all assets to CSV. Returns (success, csvContent) on success or (false, null) on failure.
  Future<({bool success, String? csvContent})> exportAssets() async {
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.exportAssets();

    _isExporting = false;
    if (result.success) {
      _errorMessage = null;
      notifyListeners();
      return (success: true, csvContent: result.csvContent);
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return (success: false, csvContent: null);
  }

  /// Bulk import assets from CSV/Excel file. On success refreshes the list. Returns (true, message) or (false, null).
  Future<({bool success, String? message})> importAssets({
    required List<int> fileBytes,
    required String filename,
  }) async {
    _isImporting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.importAssets(
      fileBytes: fileBytes,
      filename: filename,
    );

    _isImporting = false;
    if (result.success) {
      _errorMessage = null;
      await fetchAssets();
      notifyListeners();
      return (success: true, message: result.message);
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return (success: false, message: null);
  }

  /// Assigns multiple assets to an employee. On success refreshes the assets list. Returns true on success.
  Future<bool> assignAssetsToEmployee({
    required String employeeId,
    required List<String> assetIds,
    String? notes,
  }) async {
    if (assetIds.isEmpty) return false;
    final result = await _repository.assignAssetsToEmployee(
      employeeId: employeeId,
      assetIds: assetIds,
      notes: notes,
    );
    if (result.success) {
      _errorMessage = null;
      fetchAssets();
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }
}

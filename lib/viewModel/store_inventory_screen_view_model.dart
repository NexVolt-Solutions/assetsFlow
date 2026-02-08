import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/repository/store_repository.dart';
import 'package:flutter/material.dart';

class StoreInventoryScreenViewModel extends ChangeNotifier {
  StoreInventoryScreenViewModel({required StoreRepository repository})
      : _repository = repository;

  final StoreRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AssetItem> _storeAssets = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AssetItem> get storeAssets => List.unmodifiable(_storeAssets);

  Future<void> fetchStoreAssets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getStoreAssets();

    _isLoading = false;
    _storeAssets = result.list;
    _errorMessage = result.errorMessage;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

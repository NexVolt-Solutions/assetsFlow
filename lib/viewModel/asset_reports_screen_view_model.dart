import 'package:asset_flow/Core/Model/report_model.dart';
import 'package:asset_flow/repository/reports_repository.dart';
import 'package:flutter/material.dart';

enum ReportPeriod { day, week, month, yearly }

extension ReportPeriodX on ReportPeriod {
  String get apiValue {
    switch (this) {
      case ReportPeriod.day:
        return 'day';
      case ReportPeriod.week:
        return 'week';
      case ReportPeriod.month:
        return 'month';
      case ReportPeriod.yearly:
        return 'year';
    }
  }

  String get label {
    switch (this) {
      case ReportPeriod.day:
        return 'Day';
      case ReportPeriod.week:
        return 'Week';
      case ReportPeriod.month:
        return 'Month';
      case ReportPeriod.yearly:
        return 'Yearly';
    }
  }
}

class AssetReportsScreenViewModel extends ChangeNotifier {
  AssetReportsScreenViewModel({required ReportsRepository repository})
      : _repository = repository;

  final ReportsRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  ReportPeriod _period = ReportPeriod.month;
  List<AssetHistoryItem> _items = [];
  int _total = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReportPeriod get period => _period;
  List<AssetHistoryItem> get items => List.unmodifiable(_items);
  int get total => _total;

  /// Set period and refetch. Default is month.
  void setPeriod(ReportPeriod p) {
    if (_period == p) return;
    _period = p;
    fetchAssetHistory();
  }

  Future<void> fetchAssetHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAssetHistory(
      period: _period.apiValue,
    );

    _isLoading = false;
    if (result.data != null) {
      _items = result.data!.items;
      _total = result.data!.total;
      _errorMessage = null;
    } else {
      _errorMessage = result.errorMessage;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:asset_flow/repository/damage_repository.dart';
import 'package:asset_flow/view/Dashboard/screens/repair_management_screen.dart';
import 'package:flutter/foundation.dart';

class RepairManagementScreenViewModel extends ChangeNotifier {
  RepairManagementScreenViewModel({required DamageRepository repository})
      : _repository = repository,
        _repairList = List.from(kDemoRepairEntries);

  final DamageRepository _repository;
  List<RepairEntry> _repairList;
  String? _errorMessage;
  String? _updatingRepairId;

  List<RepairEntry> get items => List.unmodifiable(_repairList);
  String? get errorMessage => _errorMessage;
  bool isUpdating(String repairId) => _updatingRepairId == repairId;

  int get inRepairCount =>
      _repairList.where((e) => e.status == RepairStatus.inRepair).length;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  static String _statusToApi(RepairStatus status) {
    switch (status) {
      case RepairStatus.fixed:
        return 'Fixed';
      case RepairStatus.notRepairable:
        return 'Not Repairable';
      case RepairStatus.inRepair:
        return 'Pending';
    }
  }

  /// Update repair status via API. On success updates local list. Returns true on success.
  Future<bool> updateRepairStatus(
    String repairId,
    RepairStatus newStatus, {
    String repairNotes = '',
    double repairCost = 0,
  }) async {
    _updatingRepairId = repairId;
    _errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final completedDate =
        (newStatus == RepairStatus.fixed || newStatus == RepairStatus.notRepairable)
            ? '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'
            : null;

    final result = await _repository.updateRepairStatus(
      repairId,
      repairStatus: _statusToApi(newStatus),
      repairNotes: repairNotes,
      repairCost: repairCost,
      completedDate: completedDate,
    );

    _updatingRepairId = null;
    if (result.success) {
      final i = _repairList.indexWhere((e) => e.id == repairId);
      if (i >= 0) {
        _repairList[i] = _repairList[i].copyWith(status: newStatus);
      }
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }
}

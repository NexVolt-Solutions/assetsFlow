/// Dashboard API response models.
class DashboardData {
  DashboardData({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.resignedEmployees,
    required this.onHoldEmployees,
    required this.totalAssets,
    required this.assetsInUse,
    required this.assetsInStore,
    required this.damagedAssets,
    required this.assetsUnderRepair,
    required this.recentEmployees,
    required this.recentAssets,
  });

  final int totalEmployees;
  final int activeEmployees;
  final int resignedEmployees;
  final int onHoldEmployees;
  final int totalAssets;
  final int assetsInUse;
  final int assetsInStore;
  final int damagedAssets;
  final int assetsUnderRepair;
  final List<RecentEmployeeItem> recentEmployees;
  final List<RecentAssetItem> recentAssets;

  static DashboardData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final recentEmp = json['recent_employees'];
    final recentAst = json['recent_assets'];
    return DashboardData(
      totalEmployees: _intFrom(json['total_employees']),
      activeEmployees: _intFrom(json['active_employees']),
      resignedEmployees: _intFrom(json['resigned_employees']),
      onHoldEmployees: _intFrom(json['on_hold_employees']),
      totalAssets: _intFrom(json['total_assets']),
      assetsInUse: _intFrom(json['assets_in_use']),
      assetsInStore: _intFrom(json['assets_in_store']),
      damagedAssets: _intFrom(json['damaged_assets']),
      assetsUnderRepair: _intFrom(json['assets_under_repair']),
      recentEmployees: recentEmp is List
          ? recentEmp
              .whereType<Map<String, dynamic>>()
              .map(RecentEmployeeItem.fromJson)
              .toList()
          : [],
      recentAssets: recentAst is List
          ? recentAst
              .whereType<Map<String, dynamic>>()
              .map(RecentAssetItem.fromJson)
              .toList()
          : [],
    );
  }

  static int _intFrom(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class RecentEmployeeItem {
  RecentEmployeeItem({
    required this.id,
    required this.name,
    required this.department,
    required this.status,
  });

  final String id;
  final String name;
  final String department;
  final String status;

  static RecentEmployeeItem fromJson(Map<String, dynamic> json) {
    return RecentEmployeeItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class RecentAssetItem {
  RecentAssetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStatus,
  });

  final String id;
  final String name;
  final String category;
  final String currentStatus;

  static RecentAssetItem fromJson(Map<String, dynamic> json) {
    return RecentAssetItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      currentStatus: json['current_status']?.toString() ?? '',
    );
  }
}

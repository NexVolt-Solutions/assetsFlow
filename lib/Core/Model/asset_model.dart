/// Single asset item for the Assets screen.
class AssetItem {
  final String id;
  final String name;
  final String assetId;
  final String category;
  final String status;
  final String brand;
  final String model;
  final String condition;
  final String assignedTo;
  /// When in store, optional name of employee who last returned it.
  final String? lastReturnedBy;

  AssetItem({
    required this.id,
    required this.name,
    required this.assetId,
    required this.category,
    required this.status,
    required this.brand,
    required this.model,
    required this.condition,
    required this.assignedTo,
    this.lastReturnedBy,
  });

  static AssetItem? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final assetId = json['asset_id']?.toString() ?? json['assetId']?.toString() ?? json['asset_code']?.toString() ?? '';
    final category = json['category']?.toString() ?? '';
    final status = json['current_status']?.toString() ?? json['status']?.toString() ?? '';
    final brand = json['brand']?.toString() ?? '';
    final model = json['model']?.toString() ?? '';
    final condition = json['condition']?.toString() ?? '';
    final assignedTo = json['assigned_to']?.toString() ?? json['assignedTo']?.toString() ?? '—';
    final lastReturnedBy = json['last_returned_by']?.toString() ?? json['lastReturnedBy']?.toString();
    return AssetItem(
      id: id,
      name: name,
      assetId: assetId,
      category: category,
      status: status,
      brand: brand,
      model: model,
      condition: condition,
      assignedTo: assignedTo,
      lastReturnedBy: lastReturnedBy,
    );
  }
}

/// Request body for POST Add Asset API.
class AddAssetRequest {
  final String assetCode;
  final String name;
  final String category;
  final String brand;
  final String model;
  final String version;
  final String condition;
  final String currentStatus;

  AddAssetRequest({
    required this.assetCode,
    required this.name,
    required this.category,
    required this.brand,
    required this.model,
    required this.version,
    required this.condition,
    this.currentStatus = 'Store',
  });
}

/// Request body for PATCH Edit Asset API.
class UpdateAssetRequest {
  final String name;
  final String category;
  final String brand;
  final String model;
  final String version;
  final String condition;
  final String? currentStatus;

  UpdateAssetRequest({
    required this.name,
    required this.category,
    required this.brand,
    required this.model,
    required this.version,
    required this.condition,
    this.currentStatus,
  });
}

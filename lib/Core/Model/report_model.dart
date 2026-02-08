/// Single asset history record from Get Asset History API.
class AssetHistoryItem {
  final String id;
  final String assetName;
  final String assetCode;
  final String employeeName;
  final String action;
  final String date;

  AssetHistoryItem({
    required this.id,
    required this.assetName,
    required this.assetCode,
    required this.employeeName,
    required this.action,
    required this.date,
  });

  static AssetHistoryItem? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return AssetHistoryItem(
      id: json['id']?.toString() ?? '',
      assetName: json['asset_name']?.toString() ?? json['assetName']?.toString() ?? '',
      assetCode: json['asset_code']?.toString() ?? json['assetCode']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? json['employeeName']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}

/// Response of GET asset history: total count and list of items.
class AssetHistoryResponse {
  final int total;
  final List<AssetHistoryItem> items;

  AssetHistoryResponse({required this.total, required this.items});
}

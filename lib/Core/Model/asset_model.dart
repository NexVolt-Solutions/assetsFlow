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
  });
}

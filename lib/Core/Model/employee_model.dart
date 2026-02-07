/// Employee list item for dashboard/employee screens.
class EmployeeItem {
  final String id;
  final String name;
  final String initials;
  final String code;
  final String department;
  final String status;
  final String joiningDate;
  final String? resignationDate;
  final List<AssignedAsset> assignedAssets;

  EmployeeItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.code,
    required this.department,
    required this.status,
    required this.joiningDate,
    this.resignationDate,
    required this.assignedAssets,
  });
}

/// Asset assigned to an employee.
class AssignedAsset {
  final String name;
  final String assetId;
  final String status;

  AssignedAsset({
    required this.name,
    required this.assetId,
    required this.status,
  });
}

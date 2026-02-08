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

  static String initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts[0];
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    return ((parts[0].isNotEmpty ? parts[0][0] : '') +
            (parts[1].isNotEmpty ? parts[1][0] : ''))
        .toUpperCase();
  }

  static EmployeeItem? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? json['username']?.toString() ?? '';
    final code = json['employee_code']?.toString() ?? json['code']?.toString() ?? '';
    final department = json['department']?.toString() ?? '';
    final status = json['status']?.toString() ?? '';
    final joining = json['joining_date']?.toString() ?? json['joiningDate']?.toString() ?? '';
    final resign = json['resignation_date']?.toString() ?? json['resignationDate']?.toString();
    final assetsRaw = json['assigned_assets'] ?? json['assignedAssets'] ?? json['assets'];
    final assignedAssets = assetsRaw is List
        ? assetsRaw
            .whereType<Map<String, dynamic>>()
            .map(AssignedAsset.fromJson)
            .toList()
        : <AssignedAsset>[];
    return EmployeeItem(
      id: id,
      name: name,
      initials: initialsFromName(name),
      code: code,
      department: department,
      status: status,
      joiningDate: joining,
      resignationDate: resign,
      assignedAssets: assignedAssets,
    );
  }
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

  static AssignedAsset fromJson(Map<String, dynamic> json) {
    return AssignedAsset(
      name: json['name']?.toString() ?? '',
      assetId: json['asset_id']?.toString() ?? json['assetId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

/// Request body for POST Add Employee API.
class AddEmployeeRequest {
  final String username;
  final String email;
  final String password;
  final String department;
  final String status;
  final String joiningDate;
  final String? resignationDate;

  AddEmployeeRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.department,
    required this.status,
    required this.joiningDate,
    this.resignationDate,
  });
}

/// Request body for PATCH Update Employee API.
class UpdateEmployeeRequest {
  final String username;
  final String department;
  final String status;
  final String? resignationDate;

  UpdateEmployeeRequest({
    required this.username,
    required this.department,
    required this.status,
    this.resignationDate,
  });
}

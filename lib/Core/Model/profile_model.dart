/// Current user profile from Get Profile API.
class UserProfile {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String username;
  final String department;
  final String status;
  final String joiningDate;
  final String? resignationDate;

  UserProfile({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.username,
    required this.department,
    required this.status,
    required this.joiningDate,
    this.resignationDate,
  });

  bool get isActive => status.trim().toLowerCase() == 'active';

  static UserProfile? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return UserProfile(
      id: json['id']?.toString() ?? '',
      employeeCode:
          json['employee_code']?.toString() ?? json['employeeCode']?.toString() ?? '',
      fullName:
          json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      joiningDate:
          json['joining_date']?.toString() ?? json['joiningDate']?.toString() ?? '',
      resignationDate: json['resignation_date']?.toString() ??
          json['resignationDate']?.toString(),
    );
  }
}

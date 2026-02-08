/// API configuration and endpoint constants.
/// Use HTTPS base URL in production.
library;

/// Base URL for all API requests. Must use HTTPS in production.
const String kBaseUrl = 'https://api.nexvoltsolutions.com';

/// API path prefix per backend: /api/v1
const String kApiVersion = '/api/v1';

/// Full base URL including version: e.g. https://api.example.com/v1
String get kApiBaseUrl => '$kBaseUrl$kApiVersion';

/// Default connection timeout for API requests (seconds).
const Duration kConnectionTimeout = Duration(seconds: 30);

/// Default receive timeout for API requests (seconds).
const Duration kReceiveTimeout = Duration(seconds: 30);

/// Common header keys.
class ApiHeaders {
  ApiHeaders._();

  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';
  static const String acceptLanguage = 'Accept-Language';
}

/// Common content types.
class ApiContentType {
  ApiContentType._();

  static const String json = 'application/json';
  static const String formUrlEncoded = 'application/x-www-form-urlencoded';
}

class AuthEndpoints {
  AuthEndpoints._();

  static const String signup = 'auth/auth/signup';
  static const String login = 'auth/auth/login';
  static const String refresh = 'auth/auth/refresh';
  static const String logout = 'auth/auth/logout';
}

class DashboardEndpoints {
  DashboardEndpoints._();

  /// GET dashboard stats + recent employees/assets
  static const String dashboard = 'dashboard/dashboard/';
}

class EmployeeEndpoints {
  EmployeeEndpoints._();

  /// GET list employees (query: status, department, page, limit). POST to create.
  static const String list = 'employees/employees/';

  /// GET employee detail by id (path: employees/employees/{id}/).
  static String detail(String employeeId) => 'employees/employees/$employeeId/';
}

class AssetEndpoints {
  AssetEndpoints._();

  /// GET list assets (query: category, current_status, page, limit). POST to create.
  static const String list = 'assets/assets/';

  /// PATCH asset by id (path: assets/assets/{id}/).
  static String detail(String assetId) => 'assets/assets/$assetId/';

  /// POST assign multiple assets to an employee (query: employee_id, notes). Body: list of asset ids.
  static const String assign = 'assets/assets/assign';

  /// POST return asset to store (path: assets/assets/{id}/return). Query: optional notes.
  static String returnToStore(String assetId) => 'assets/assets/$assetId/return';

  /// POST report damaged asset (path: assets/assets/{id}/report-damage). Query: employee_id, reason, damage_date.
  static String reportDamage(String assetId) => 'assets/assets/$assetId/report-damage';

  /// POST bulk import assets from CSV/Excel. Body: multipart file (field name: file).
  static const String import = 'assets/assets/import';

  /// GET export all assets to CSV. Response body is CSV string.
  static const String export = 'assets/assets/export';
}

class StoreEndpoints {
  StoreEndpoints._();

  /// GET list all assets currently in Store / Inventory. Response: array of asset objects.
  static const String list = 'store/store/';
}

class DamageEndpoints {
  DamageEndpoints._();

  /// GET list all damaged assets. Response: { total, items } (items are asset objects).
  static const String list = 'damage/damaged/';

  /// POST send damaged asset to repair (path: damage/damaged/{id}/send-to-repair). Body: asset_id, repair_status, repair_notes, repair_cost, sent_date, completed_date.
  static String sendToRepair(String assetId) => 'damage/damaged/$assetId/send-to-repair';

  /// PUT update repair status (path: damage/damaged/{repair_id}/update). Body: repair_status, repair_notes, repair_cost, completed_date.
  static String updateRepair(String repairId) => 'damage/damaged/$repairId/update';

  /// DELETE remove damaged asset permanently (path: damage/damaged/{asset_id}/remove).
  static String removeDamaged(String assetId) => 'damage/damaged/$assetId/remove';
}

class ReportsEndpoints {
  ReportsEndpoints._();

  /// GET asset history. Query: period (day/week/month/year, default: month).
  static const String history = 'reports/reports/history';
}

class ProfileEndpoints {
  ProfileEndpoints._();

  /// GET current user profile. No parameters.
  static const String me = 'profile/profile/me';

  /// PUT update current user profile. Body: full_name, email, username, department, status.
  static const String update = 'profile/profile/update';

  /// POST change password. Body: current_password, new_password, confirm_new_password.
  static const String changePassword = 'profile/profile/change-password';
}

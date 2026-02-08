/// API configuration and endpoint constants.
/// Use HTTPS base URL in production.
library;

/// Base URL for all API requests. Must use HTTPS in production.
const String kBaseUrl = 'https://api.nexvoltsolutions.com';

/// API version prefix (e.g. /v1). Set to empty string if no version in path.
const String kApiVersion = '/v1';

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

/// Auth API paths (relative to [kApiBaseUrl]).
class AuthEndpoints {
  AuthEndpoints._();

  static const String signup = 'auth/auth/signup';
}

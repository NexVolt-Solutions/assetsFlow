/// Abstract API client for clean architecture.
/// Implementations (e.g. [BaseApiService]) can be swapped for testing or different backends.
library;

/// Contract for HTTP API calls. Use [BaseApiService] for the concrete HTTPS implementation.
abstract interface class ApiClientInterface {
  String get baseUrl;

  Future<ApiResult<dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResult<dynamic>> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResult<dynamic>> put(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResult<dynamic>> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResult<dynamic>> delete(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Object? body,
  });

  /// POST multipart file upload. [fileField] is the form field name, [fileBytes] the file content, [filename] the file name.
  Future<ApiResult<dynamic>> postMultipart(
    String path, {
    required String fileField,
    required List<int> fileBytes,
    required String filename,
    Map<String, String>? fields,
    Map<String, String>? headers,
  });
}

/// Result of an API call. [T] is the decoded response body type.
sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess({
    required this.statusCode,
    this.body,
    this.rawBody,
  });

  final int statusCode;
  final T? body;
  final String? rawBody;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure({
    required this.message,
    this.statusCode,
    this.rawBody,
  });

  final String message;
  final int? statusCode;
  final String? rawBody;
}

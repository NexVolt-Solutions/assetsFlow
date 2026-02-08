import 'dart:convert';

import 'package:asset_flow/Core/Constants/api_constants.dart';
import 'package:asset_flow/Core/Network/api_client_interface.dart';
import 'package:http/http.dart' as http;

/// Base API service for HTTP over HTTPS.
/// Implements [ApiClientInterface] for clean architecture (testable, swappable).
/// Provides GET, POST, PUT, PATCH, DELETE with consistent headers, timeouts, and error handling.
class BaseApiService implements ApiClientInterface {
  BaseApiService({
    String? baseUrl,
    Duration? connectionTimeout,
    Duration? receiveTimeout,
    Map<String, String>? defaultHeaders,
    String? authToken,
    String? Function()? tokenGetter,
    Future<String?> Function()? on401Refresh,
  })  : _baseUrl = baseUrl ?? kApiBaseUrl,
        _connectionTimeout = connectionTimeout ?? kConnectionTimeout,
        _receiveTimeout = receiveTimeout ?? kReceiveTimeout,
        _tokenGetter = tokenGetter,
        _on401Refresh = on401Refresh,
        _defaultHeaders = {
          ApiHeaders.contentType: ApiContentType.json,
          ApiHeaders.accept: ApiContentType.json,
          ...?defaultHeaders,
          if (tokenGetter == null && authToken != null && authToken.isNotEmpty)
            ApiHeaders.authorization: 'Bearer $authToken',
        };

  final String _baseUrl;
  final Duration _connectionTimeout;
  final Duration _receiveTimeout;
  final Map<String, String> _defaultHeaders;
  final String? Function()? _tokenGetter;
  final Future<String?> Function()? _on401Refresh;

  String get baseUrl => _baseUrl;

  /// Updates the auth token by creating a new service with the same config.
  BaseApiService copyWith({String? authToken}) {
    return BaseApiService(
      baseUrl: _baseUrl,
      connectionTimeout: _connectionTimeout,
      receiveTimeout: _receiveTimeout,
      defaultHeaders: _defaultHeaders,
      authToken: authToken,
    );
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final pathNormalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$pathNormalized');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    final base = {..._defaultHeaders, ...?headers};
    if (_tokenGetter != null) {
      final token = _tokenGetter();
      if (token != null && token.isNotEmpty) {
        base[ApiHeaders.authorization] = 'Bearer $token';
      }
    }
    return base;
  }

  Future<ApiResult<dynamic>> _retryOn401(Future<ApiResult<dynamic>> Function() run) async {
    var result = await run();
    if (result case ApiFailure(statusCode: int code) when code == 401 && _on401Refresh != null) {
      final newToken = await _on401Refresh();
      if (newToken != null) result = await run();
    }
    return result;
  }

  Future<ApiResult<dynamic>> _handleResponse(http.Response response) async {
    final rawBody = response.body;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      dynamic body;
      if (rawBody.isNotEmpty) {
        try {
          body = jsonDecode(rawBody);
        } catch (_) {
          body = rawBody;
        }
      }
      return ApiSuccess<dynamic>(
        statusCode: response.statusCode,
        body: body,
        rawBody: rawBody,
      );
    }
    return ApiFailure<dynamic>(
      message: _errorMessageFromResponse(response),
      statusCode: response.statusCode,
      rawBody: rawBody,
    );
  }

  String _errorMessageFromResponse(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        final map = jsonDecode(response.body) as Map<String, dynamic>?;
        final msg = map?['message'] ?? map?['error'] ?? map?['msg'];
        if (msg != null) return msg.toString();
      } catch (_) {}
    }
    return 'Request failed with status ${response.statusCode}';
  }

  /// GET request. On 401, calls [on401Refresh] and retries once if new token is returned.
  Future<ApiResult<dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _retryOn401(() async {
      try {
        final uri = _buildUri(path, queryParameters);
        final response = await http
            .get(uri, headers: _mergeHeaders(headers))
            .timeout(_connectionTimeout + _receiveTimeout);
        return _handleResponse(response);
      } catch (e) {
        return ApiFailure<dynamic>(message: e.toString());
      }
    });
  }

  /// POST request with JSON body. On 401, calls [on401Refresh] and retries once.
  Future<ApiResult<dynamic>> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _retryOn401(() async {
      try {
        final uri = _buildUri(path, queryParameters);
        final encoded = body != null ? jsonEncode(body) : null;
        final response = await http
            .post(uri, headers: _mergeHeaders(headers), body: encoded)
            .timeout(_connectionTimeout + _receiveTimeout);
        return _handleResponse(response);
      } catch (e) {
        return ApiFailure<dynamic>(message: e.toString());
      }
    });
  }

  /// PUT request with JSON body. On 401, calls [on401Refresh] and retries once.
  Future<ApiResult<dynamic>> put(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _retryOn401(() async {
      try {
        final uri = _buildUri(path, queryParameters);
        final encoded = body != null ? jsonEncode(body) : null;
        final response = await http
            .put(uri, headers: _mergeHeaders(headers), body: encoded)
            .timeout(_connectionTimeout + _receiveTimeout);
        return _handleResponse(response);
      } catch (e) {
        return ApiFailure<dynamic>(message: e.toString());
      }
    });
  }

  /// PATCH request with JSON body. On 401, calls [on401Refresh] and retries once.
  Future<ApiResult<dynamic>> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _retryOn401(() async {
      try {
        final uri = _buildUri(path, queryParameters);
        final encoded = body != null ? jsonEncode(body) : null;
        final response = await http
            .patch(uri, headers: _mergeHeaders(headers), body: encoded)
            .timeout(_connectionTimeout + _receiveTimeout);
        return _handleResponse(response);
      } catch (e) {
        return ApiFailure<dynamic>(message: e.toString());
      }
    });
  }

  /// DELETE request. On 401, calls [on401Refresh] and retries once.
  Future<ApiResult<dynamic>> delete(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _retryOn401(() async {
      try {
        final uri = _buildUri(path, queryParameters);
        final encoded = body != null ? jsonEncode(body) : null;
        final response = await http
            .delete(uri, headers: _mergeHeaders(headers), body: encoded)
            .timeout(_connectionTimeout + _receiveTimeout);
        return _handleResponse(response);
      } catch (e) {
        return ApiFailure<dynamic>(message: e.toString());
      }
    });
  }

  /// POST multipart file upload. Does not set Content-Type (multipart sets it with boundary).
  @override
  Future<ApiResult<dynamic>> postMultipart(
    String path, {
    required String fileField,
    required List<int> fileBytes,
    required String filename,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    return _retryOn401(() async {
      try {
        final uri = _buildUri(path);
        final request = http.MultipartRequest('POST', uri);
        final h = _mergeHeaders(headers);
        h.remove(ApiHeaders.contentType);
        request.headers.addAll(h);
        request.files.add(http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: filename,
        ));
        if (fields != null) {
          request.fields.addAll(fields);
        }
        final streamed = await request.send().timeout(_connectionTimeout + _receiveTimeout);
        final response = await http.Response.fromStream(streamed);
        return _handleResponse(response);
      } catch (e) {
        return ApiFailure<dynamic>(message: e.toString());
      }
    });
  }
}

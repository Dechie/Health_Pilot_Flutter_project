import 'package:dio/dio.dart';
import 'package:healthpilot/core/env/app_env.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/network/api_interceptors.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';

class ApiClient {
  ApiClient._internal(this._dio);

  static ApiClient? _instance;
  final Dio _dio;

  /// Must be called once at app startup before [instance] is accessed.
  static void initialize({
    required SecureTokenStore tokenStore,
    required Future<void> Function() onAuthExpired,
  }) {
    if (_instance != null) return;
    final dio = Dio(BaseOptions(
      baseUrl: AppEnv.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ));
    dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(
        dio: dio,
        tokenStore: tokenStore,
        onAuthExpired: onAuthExpired,
      ),
      EnvelopeInterceptor(),
    ]);
    _instance = ApiClient._internal(dio);
  }

  static ApiClient get instance {
    assert(_instance != null, 'ApiClient.initialize() must be called before use');
    return _instance!;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final r = await _dio.get(path, queryParameters: queryParameters, options: options);
      return r.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final r = await _dio.post(path, data: data, options: options);
      return r.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final r = await _dio.patch(path, data: data, options: options);
      return r.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    Options? options,
  }) async {
    try {
      final r = await _dio.delete(path, options: options);
      return r.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Extracts a human-readable message from a response body, covering the
  /// backend's envelope format (`message`) and DRF defaults (`detail`,
  /// `non_field_errors`).
  static String? _extractMessage(dynamic body) {
    if (body is! Map) return null;
    // Top-level envelope message (success responses / some errors)
    if (body['message'] case final String m) return m;
    // Nested error envelope: {error: {details: {non_field_errors: [...]}}}
    if (body['error'] case final Map error) {
      final details = error['details'];
      if (details is Map) {
        final nonField = details['non_field_errors'];
        if (nonField is List && nonField.isNotEmpty) {
          return nonField.first.toString();
        }
        // First field-level error message
        for (final v in details.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String) return v;
        }
      }
      if (error['message'] case final String m) return m;
    }
    // DRF defaults
    if (body['detail'] case final String d) return d;
    final nonField = body['non_field_errors'];
    if (nonField is List && nonField.isNotEmpty) {
      return nonField.first.toString();
    }
    return null;
  }

  static ApiException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return NetworkError(e.message);
      case DioExceptionType.badResponse:
        final response = e.response;
        if (response?.statusCode == 401) return const AuthExpired();
        final body = response?.data;
        final message = _extractMessage(body) ??
            'Unexpected error (${response?.statusCode ?? 0})';
        final code = body is Map ? body['code'] as String? : null;
        return ServerError(
          statusCode: response?.statusCode ?? 0,
          code: code,
          message: message,
        );
      default:
        return UnknownError(e);
    }
  }
}

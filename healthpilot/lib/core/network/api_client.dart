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
    required void Function() onAuthExpired,
  }) {
    if (_instance != null) return;
    final dio = Dio(BaseOptions(
      baseUrl: AppEnv.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ));
    dio.interceptors.addAll([
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
        final message = e.message ??
            (body is Map ? body['message'] as String? : null) ??
            'Unknown server error';
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

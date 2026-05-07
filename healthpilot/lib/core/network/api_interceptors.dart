import 'package:dio/dio.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';

/// Injects the Authorization header and handles transparent token refresh on 401.
/// Uses a separate plain Dio for the refresh call to avoid re-entering this interceptor.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureTokenStore _tokenStore;
  final void Function() _onAuthExpired;

  AuthInterceptor({
    required Dio dio,
    required SecureTokenStore tokenStore,
    required void Function() onAuthExpired,
  })  : _dio = dio,
        _tokenStore = tokenStore,
        _onAuthExpired = onAuthExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStore.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Skip if already a retry to prevent infinite loop.
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra['_retried'] == true) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStore.getRefreshToken();
    if (refreshToken == null) {
      await _tokenStore.clearAll();
      _onAuthExpired();
      handler.reject(err);
      return;
    }

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final refreshResp = await refreshDio.post(
        '${ApiConstants.authBase}/token/refresh/',
        data: {'refresh': refreshToken},
      );
      final body = refreshResp.data as Map<String, dynamic>;
      final inner = (body['data'] ?? body) as Map<String, dynamic>;
      final newAccess = inner['access'] as String;
      await _tokenStore.setAccessToken(newAccess);

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccess'
        ..extra['_retried'] = true;
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _tokenStore.clearAll();
      _onAuthExpired();
      handler.reject(err);
    }
  }
}

/// Unwraps the `{ "success": bool, "message": "...", "data": {...} }` envelope.
/// Replaces response.data with the inner data object on success.
/// Rejects with the server message when success is false.
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final success = body['success'] as bool? ?? true;
      if (!success) {
        handler.reject(DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: body['message'] as String? ?? 'Request failed',
        ));
        return;
      }
      response.data = body.containsKey('data') ? body['data'] : body;
    }
    handler.next(response);
  }
}

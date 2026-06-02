import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';
import 'package:path_provider/path_provider.dart';

/// Injects the Authorization header and handles transparent token refresh on 401.
/// Uses a separate plain Dio for the refresh call to avoid re-entering this interceptor.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureTokenStore _tokenStore;
  final Future<void> Function() _onAuthExpired;

  AuthInterceptor({
    required Dio dio,
    required SecureTokenStore tokenStore,
    required Future<void> Function() onAuthExpired,
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
      await _onAuthExpired();
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
      await _onAuthExpired();
      handler.reject(err);
    }
  }
}

/// Logs every request and response to the debug console AND a file
/// at `<documents>/dio_logs.txt` (debug builds only).
/// Pull the file with: adb pull $(adb shell run-as com.example.healthpilot \
///   cat /data/data/com.example.healthpilot/files/dio_logs.txt) ./dio_logs.txt
/// Or watch it live in the terminal (see README).
class LoggingInterceptor extends Interceptor {
  static File? _logFile;

  static Future<void> init() async {
    if (!kDebugMode) return;
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/dio_logs.txt');
    // Clear previous session's log on each app start.
    await _logFile!.writeAsString(
      '=== Session started ${DateTime.now()} ===\n',
    );
  }

  static void _write(String block) {
    if (!kDebugMode) return;
    debugPrint(block);
    _logFile?.writeAsStringSync('$block\n', mode: FileMode.append, flush: true);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final headers = Map<String, dynamic>.from(options.headers)
        ..update('Authorization', (v) => '${(v as String).substring(0, 15)}…', ifAbsent: () => null)
        ..removeWhere((_, v) => v == null);
      _write(
        '┌── REQUEST ─────────────────────────────────\n'
        '│ ${options.method} ${options.uri}\n'
        '│ Headers: $headers\n'
        '${options.data != null ? '│ Body: ${options.data}\n' : ''}'
        '└────────────────────────────────────────────',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _write(
        '┌── RESPONSE ────────────────────────────────\n'
        '│ ${response.statusCode} ${response.requestOptions.uri}\n'
        '│ Body: ${response.data}\n'
        '└────────────────────────────────────────────',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _write(
        '┌── ERROR ───────────────────────────────────\n'
        '│ ${err.response?.statusCode ?? 'NO STATUS'} ${err.requestOptions.uri}\n'
        '│ Body: ${err.response?.data}\n'
        '└────────────────────────────────────────────',
      );
    }
    handler.next(err);
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

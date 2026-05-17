sealed class ApiException implements Exception {
  const ApiException();

  /// Human-readable message safe to show directly in the UI.
  /// 4xx errors surface the backend message (user-actionable).
  /// 5xx and unknown errors return a generic string so internal
  /// server details are never exposed to users.
  String get userMessage => switch (this) {
        ServerError(:final statusCode, :final message)
            when statusCode < 500 =>
          message,
        ServerError() =>
          'Something went wrong on our end. Please try again later.',
        NetworkError() => 'No internet connection.',
        AuthExpired() => 'Session expired. Please log in again.',
        UnknownError() => 'Something went wrong. Please try again.',
      };
}

final class NetworkError extends ApiException {
  final String? message;
  const NetworkError([this.message]);

  @override
  String toString() => 'NetworkError(${message ?? 'no connection'})';
}

final class ServerError extends ApiException {
  final int statusCode;
  final String? code;
  final String message;
  const ServerError({required this.statusCode, this.code, required this.message});

  @override
  String toString() => 'ServerError($statusCode: $message)';
}

final class AuthExpired extends ApiException {
  const AuthExpired();

  @override
  String toString() => 'AuthExpired()';
}

final class UnknownError extends ApiException {
  final Object? cause;
  const UnknownError([this.cause]);

  @override
  String toString() => 'UnknownError($cause)';
}

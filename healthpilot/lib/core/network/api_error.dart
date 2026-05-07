sealed class ApiException implements Exception {
  const ApiException();
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

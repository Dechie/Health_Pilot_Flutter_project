import 'package:healthpilot/core/auth/auth_tokens.dart';

abstract class IAuthRepository {
  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  });

  Future<AuthTokens> activate({required String token});

  Future<void> resendActivation({required String email});

  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<AuthTokens> refreshToken({required String refresh});

  Future<void> logout({required String refresh});

  Future<AuthTokens> guestLogin();

  Future<Map<String, dynamic>> getMe();

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> fields);

  /// Change the password of the authenticated user.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Request a password-reset email for [email].
  Future<void> requestPasswordReset({required String email});

  /// Complete a password reset using the emailed [token].
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  });

  /// Permanently delete the authenticated user's account.
  Future<void> deleteAccount();
}

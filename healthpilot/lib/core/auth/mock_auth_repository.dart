import 'package:healthpilot/core/auth/auth_tokens.dart';
import 'package:healthpilot/core/repositories/i_auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  static const _tokens = AuthTokens(
    access: 'mock_access_token',
    refresh: 'mock_refresh_token',
    userId: '123',
  );

  static const _demoUser = <String, dynamic>{
    'id': 1,
    'first_name': 'Demo',
    'last_name': 'User',
    'email': 'demo@healthpilot.com',
  };

  @override
  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {}

  @override
  Future<AuthTokens> activate({required String token}) async => _tokens;

  @override
  Future<void> resendActivation({required String email}) async {}

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async =>
      _tokens;

  @override
  Future<AuthTokens> refreshToken({required String refresh}) async => _tokens;

  @override
  Future<void> logout({required String refresh}) async {}

  @override
  Future<AuthTokens> guestLogin() async => _tokens;

  @override
  Future<Map<String, dynamic>> getMe() async => Map.of(_demoUser);

  @override
  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> fields) async =>
      {..._demoUser, ...fields};
}

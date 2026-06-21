import 'package:healthpilot/core/auth/auth_tokens.dart';
import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_auth_repository.dart';

class RemoteAuthRepository implements IAuthRepository {
  final ApiClient _client;

  const RemoteAuthRepository(this._client);

  @override
  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    await _client.post('${ApiConstants.authBase}/register/', data: {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'password2': password,
    });
  }

  @override
  Future<AuthTokens> activate({required String token}) async {
    // Email links use GET ?token=…; same endpoint, no manual POST body needed.
    final data = await _client.get(
      '${ApiConstants.authBase}/activate/',
      queryParameters: {'token': token},
    );
    return AuthTokens.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> resendActivation({required String email}) async {
    await _client.post(
      '${ApiConstants.authBase}/resend-activation/',
      data: {'email': email},
    );
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      '${ApiConstants.authBase}/login/',
      data: {'email': email, 'password': password},
    );
    return AuthTokens.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<AuthTokens> refreshToken({required String refresh}) async {
    final data = await _client.post(
      '${ApiConstants.authBase}/token/refresh/',
      data: {'refresh': refresh},
    );
    return AuthTokens.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> logout({required String refresh}) async {
    await _client.post(
      '${ApiConstants.authBase}/logout/',
      data: {'refresh': refresh},
    );
  }

  @override
  Future<AuthTokens> guestLogin() async {
    final data = await _client.post('${ApiConstants.authBase}/guest/');
    return AuthTokens.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    final data = await _client.get('${ApiConstants.authBase}/me/');
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> fields) async {
    final data = await _client.patch(
      '${ApiConstants.authBase}/me/',
      data: fields,
    );
    return data as Map<String, dynamic>;
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.post('${ApiConstants.authBase}/password/change/', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password2': newPassword,
    });
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _client.post(
      '${ApiConstants.authBase}/password/reset/',
      data: {'email': email},
    );
  }

  @override
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await _client.post('${ApiConstants.authBase}/password/reset/confirm/', data: {
      'token': token,
      'new_password': newPassword,
      'new_password2': newPassword,
    });
  }

  @override
  Future<void> deleteAccount() async {
    await _client.delete('${ApiConstants.authBase}/me/delete/');
  }
}

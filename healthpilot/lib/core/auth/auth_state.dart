import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/auth/auth_tokens.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/repositories/i_auth_repository.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  final IAuthRepository _repo;
  final SecureTokenStore _tokenStore;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  String _firstName = '';
  String _lastName = '';
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get fullName => [_firstName, _lastName]
      .where((s) => s.isNotEmpty)
      .join(' ');

  AuthState({
    required IAuthRepository repo,
    required SecureTokenStore tokenStore,
  })  : _repo = repo,
        _tokenStore = tokenStore;

  /// Called once from WelcomeScreen. Resolves to the correct AuthStatus.
  /// When FF_AUTH is false, immediately resolves as authenticated (mock mode).
  Future<void> initialize() async {
    if (!FeatureFlags.auth) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return;
    }
    final token = await _tokenStore.getAccessToken();
    _status = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    _firstName = await _tokenStore.getFirstName() ?? '';
    _lastName  = await _tokenStore.getLastName()  ?? '';
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final tokens = await _repo.login(email: email, password: password);
    await _storeTokens(tokens);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    await _repo.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
    );
    // Status unchanged — user must activate via email token before logging in.
  }

  Future<void> activate(String token) async {
    final tokens = await _repo.activate(token: token);
    await _storeTokens(tokens);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      final refresh = await _tokenStore.getRefreshToken();
      if (refresh != null) await _repo.logout(refresh: refresh);
    } catch (_) {
      // Best-effort — always clear local tokens regardless.
    }
    await _tokenStore.clearAll();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Called by ApiClient interceptor when the refresh token is expired or missing.
  void onAuthExpired() {
    _tokenStore.clearAll();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _storeTokens(AuthTokens tokens) async {
    await _tokenStore.setAccessToken(tokens.access);
    await _tokenStore.setRefreshToken(tokens.refresh);
    if (tokens.firstName.isNotEmpty) {
      await _tokenStore.setFirstName(tokens.firstName);
      _firstName = tokens.firstName;
    }
    if (tokens.lastName.isNotEmpty) {
      await _tokenStore.setLastName(tokens.lastName);
      _lastName = tokens.lastName;
    }
  }
}

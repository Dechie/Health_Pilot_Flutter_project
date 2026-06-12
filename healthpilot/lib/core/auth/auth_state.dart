import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/auth/auth_tokens.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/repositories/i_auth_repository.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthState extends ChangeNotifier {
  final IAuthRepository _repo;
  final SecureTokenStore _tokenStore;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  String _firstName = '';
  String _lastName = '';
  bool _isGuest = false;
  bool _onboardingCompleted = false;
  bool _healthInfoCompleted = false;
  bool _activationPending = false;
  String _pendingActivationEmail = '';
  int  _onboardingStep = 0;
  String get firstName => _firstName;
  String get lastName => _lastName;
  bool get isGuest => _isGuest;
  bool get isOnboardingCompleted => _onboardingCompleted;
  bool get isHealthInfoCompleted => _healthInfoCompleted;
  bool get isActivationPending => _activationPending;
  String get pendingActivationEmail => _pendingActivationEmail;
  int  get onboardingStep => _onboardingStep;
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
    _firstName           = await _tokenStore.getFirstName() ?? '';
    _lastName            = await _tokenStore.getLastName()  ?? '';
    _isGuest             = await _tokenStore.getIsGuest();
    _onboardingCompleted = await _tokenStore.getOnboardingCompleted();
    _healthInfoCompleted = await _tokenStore.getHealthInfoCompleted();
    _activationPending   = await _tokenStore.getActivationPending();
    _pendingActivationEmail =
        await _tokenStore.getPendingActivationEmail() ?? '';
    _onboardingStep      = await _tokenStore.getOnboardingStep();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final tokens = await _repo.login(email: email, password: password);
    await _storeTokens(tokens);
    await _tokenStore.setActivationPending(false);
    await _tokenStore.clearPendingActivationEmail();
    _activationPending = false;
    _pendingActivationEmail = '';
    await _tokenStore.setIsGuest(false);
    _isGuest = false;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> resendActivationEmail() async {
    final email = _pendingActivationEmail.trim();
    if (email.isEmpty) {
      throw const AuthException('No email on file. Return to sign up.');
    }
    await _repo.resendActivation(email: email);
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
    await _tokenStore.setPendingActivationEmail(email);
    await _tokenStore.setActivationPending(true);
    _pendingActivationEmail = email;
    _activationPending = true;
    // Status unchanged — user must activate via email token before logging in.
    notifyListeners();
  }

  Future<void> activate(String token) async {
    final tokens = await _repo.activate(token: token);
    await _storeTokens(tokens);
    await _tokenStore.setActivationPending(false);
    await _tokenStore.clearPendingActivationEmail();
    _activationPending = false;
    _pendingActivationEmail = '';
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> guestLogin() async {
    final tokens = await _repo.guestLogin();
    await _storeTokens(tokens);
    await _tokenStore.setIsGuest(true);
    _isGuest = true;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Enters guest mode locally without a network call — used as fallback when
  /// the backend guest-login endpoint is unreachable (e.g. no internet).
  Future<void> enterLocalGuestMode() async {
    await _clearSession();
    await _tokenStore.setIsGuest(true);
    _isGuest = true;
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
    await _clearSession();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Called by ApiClient interceptor when the refresh token is expired or missing.
  Future<void> onAuthExpired() async {
    await _clearSession();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> setOnboardingStep(int step) async {
    await _tokenStore.setOnboardingStep(step);
    _onboardingStep = step;
  }

  Future<void> markOnboardingCompleted() async {
    await _tokenStore.setOnboardingCompleted();
    await _tokenStore.setOnboardingStep(0);
    _onboardingCompleted = true;
    _onboardingStep = 0;
    notifyListeners();
  }

  Future<void> markHealthInfoCompleted() async {
    await _tokenStore.setHealthInfoCompleted(true);
    _healthInfoCompleted = true;
    notifyListeners();
  }

  Future<void> _clearSession() async {
    await _tokenStore.clearAll();
    _firstName = '';
    _lastName = '';
    _isGuest = false;
    _activationPending = false;
    _pendingActivationEmail = '';
    _onboardingCompleted = false;
    _healthInfoCompleted = false;
    _onboardingStep = 0;
  }

  Future<void> _storeTokens(AuthTokens tokens) async {
    await _tokenStore.setAccessToken(tokens.access);
    await _tokenStore.setRefreshToken(tokens.refresh);
    // Always overwrite — clears previous user's name when switching accounts.
    await _tokenStore.setFirstName(tokens.firstName);
    await _tokenStore.setLastName(tokens.lastName);
    _firstName = tokens.firstName;
    _lastName = tokens.lastName;
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStore {
  static const _accessKey = 'hp.auth.access_token';
  static const _refreshKey = 'hp.auth.refresh_token';
  static const _userIdKey = 'hp.auth.user_id';
  static const _firstNameKey = 'hp.auth.first_name';
  static const _lastNameKey = 'hp.auth.last_name';
  static const _isGuestKey = 'hp.auth.is_guest';
  static const _onboardingCompletedKey = 'hp.onboarding.completed';
  static const _onboardingStepKey = 'hp.onboarding.step';
  static const _healthInfoCompletedKey = 'hp.profile.health_info_completed';
  static const _activationPendingKey = 'hp.auth.activation_pending';
  static const _pendingActivationEmailKey = 'hp.auth.pending_activation_email';

  final FlutterSecureStorage _storage;

  const SecureTokenStore(this._storage);

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);
  Future<String?> getFirstName() => _storage.read(key: _firstNameKey);
  Future<String?> getLastName() => _storage.read(key: _lastNameKey);
  Future<bool> getIsGuest() async =>
      (await _storage.read(key: _isGuestKey)) == 'true';

  Future<void> setAccessToken(String token) =>
      _storage.write(key: _accessKey, value: token);
  Future<void> setRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);
  Future<void> setUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);
  Future<void> setFirstName(String name) =>
      _storage.write(key: _firstNameKey, value: name);
  Future<void> setLastName(String name) =>
      _storage.write(key: _lastNameKey, value: name);
  Future<void> setIsGuest(bool v) =>
      _storage.write(key: _isGuestKey, value: v.toString());

  Future<bool> getOnboardingCompleted() async =>
      (await _storage.read(key: _onboardingCompletedKey)) == 'true';
  Future<void> setOnboardingCompleted() =>
      _storage.write(key: _onboardingCompletedKey, value: 'true');

  Future<int> getOnboardingStep() async =>
      int.tryParse(await _storage.read(key: _onboardingStepKey) ?? '') ?? 0;
  Future<void> setOnboardingStep(int step) =>
      _storage.write(key: _onboardingStepKey, value: step.toString());

  /// Whether the user has completed the optional health-profile setup flow.
  Future<bool> getHealthInfoCompleted() async =>
      (await _storage.read(key: _healthInfoCompletedKey)) == 'true';
  Future<void> setHealthInfoCompleted(bool value) =>
      _storage.write(key: _healthInfoCompletedKey, value: value.toString());

  Future<bool> getActivationPending() async =>
      (await _storage.read(key: _activationPendingKey)) == 'true';
  Future<void> setActivationPending(bool v) =>
      _storage.write(key: _activationPendingKey, value: v.toString());

  Future<String?> getPendingActivationEmail() =>
      _storage.read(key: _pendingActivationEmailKey);

  Future<void> setPendingActivationEmail(String email) =>
      _storage.write(key: _pendingActivationEmailKey, value: email);

  Future<void> clearPendingActivationEmail() =>
      _storage.delete(key: _pendingActivationEmailKey);

  /// Clears all auth-session data (tokens, credentials, activation state).
  /// Onboarding progress is preserved so the user doesn't have to re-enter
  /// it after a session expiry or re-login.
  Future<void> clearAuthSession() => Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _firstNameKey),
        _storage.delete(key: _lastNameKey),
        _storage.delete(key: _isGuestKey),
        _storage.delete(key: _activationPendingKey),
        _storage.delete(key: _pendingActivationEmailKey),
      ]);

  /// Like [clearAuthSession] but also deletes user-specific profile flags
  /// (health-info) so a different account doesn't inherit them.
  /// Onboarding is still preserved (it is a device-level setup).
  Future<void> clearUserSession() => Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _firstNameKey),
        _storage.delete(key: _lastNameKey),
        _storage.delete(key: _isGuestKey),
        _storage.delete(key: _activationPendingKey),
        _storage.delete(key: _pendingActivationEmailKey),
        _storage.delete(key: _healthInfoCompletedKey),
      ]);

  /// Deletes everything including onboarding/health-info progress.
  /// Use only for account deletion / factory reset scenarios.
  Future<void> clearAll() => Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _firstNameKey),
        _storage.delete(key: _lastNameKey),
        _storage.delete(key: _isGuestKey),
        _storage.delete(key: _activationPendingKey),
        _storage.delete(key: _pendingActivationEmailKey),
        _storage.delete(key: _healthInfoCompletedKey),
        _storage.delete(key: _onboardingCompletedKey),
        _storage.delete(key: _onboardingStepKey),
      ]);
}

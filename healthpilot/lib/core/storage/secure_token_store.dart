import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStore {
  static const _accessKey     = 'hp.auth.access_token';
  static const _refreshKey    = 'hp.auth.refresh_token';
  static const _userIdKey     = 'hp.auth.user_id';
  static const _firstNameKey  = 'hp.auth.first_name';
  static const _lastNameKey   = 'hp.auth.last_name';
  static const _isGuestKey    = 'hp.auth.is_guest';

  final FlutterSecureStorage _storage;

  const SecureTokenStore(this._storage);

  Future<String?> getAccessToken()  => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> getUserId()       => _storage.read(key: _userIdKey);
  Future<String?> getFirstName()    => _storage.read(key: _firstNameKey);
  Future<String?> getLastName()     => _storage.read(key: _lastNameKey);
  Future<bool>    getIsGuest()      async =>
      (await _storage.read(key: _isGuestKey)) == 'true';

  Future<void> setAccessToken(String token)  => _storage.write(key: _accessKey,  value: token);
  Future<void> setRefreshToken(String token) => _storage.write(key: _refreshKey, value: token);
  Future<void> setUserId(String id)          => _storage.write(key: _userIdKey,  value: id);
  Future<void> setFirstName(String name)     => _storage.write(key: _firstNameKey, value: name);
  Future<void> setLastName(String name)      => _storage.write(key: _lastNameKey,  value: name);
  Future<void> setIsGuest(bool v)            => _storage.write(key: _isGuestKey,   value: v.toString());

  Future<void> clearAll() => Future.wait([
    _storage.delete(key: _accessKey),
    _storage.delete(key: _refreshKey),
    _storage.delete(key: _userIdKey),
    _storage.delete(key: _firstNameKey),
    _storage.delete(key: _lastNameKey),
    _storage.delete(key: _isGuestKey),
  ]);
}

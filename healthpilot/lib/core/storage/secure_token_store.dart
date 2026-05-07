import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStore {
  static const _accessKey  = 'hp.auth.access_token';
  static const _refreshKey = 'hp.auth.refresh_token';
  static const _userIdKey  = 'hp.auth.user_id';

  final FlutterSecureStorage _storage;

  const SecureTokenStore(this._storage);

  Future<String?> getAccessToken()  => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> getUserId()       => _storage.read(key: _userIdKey);

  Future<void> setAccessToken(String token)  => _storage.write(key: _accessKey,  value: token);
  Future<void> setRefreshToken(String token) => _storage.write(key: _refreshKey, value: token);
  Future<void> setUserId(String id)          => _storage.write(key: _userIdKey,  value: id);

  Future<void> clearAll() => Future.wait([
    _storage.delete(key: _accessKey),
    _storage.delete(key: _refreshKey),
    _storage.delete(key: _userIdKey),
  ]);
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyAccessToken = "AccessToken";
  static const String _keyUserId = "UserId";
  static const String _keyUserName = "UserName";

  // Access Token
  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyAccessToken, token);
  }

  static Future<String?> getAccessToken() async {
    String? token = await _storage.read(key: _keyAccessToken);
    if (token == null || token.isEmpty) {
      final sp = await SharedPreferences.getInstance();
      token = sp.getString(_keyAccessToken);
    }
    return token;
  }

  // User Id
  static Future<void> setUserId(String id) async {
    await _storage.write(key: _keyUserId, value: id);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyUserId, id);
  }

  static Future<String?> getUserId() async {
    String? id = await _storage.read(key: _keyUserId);
    if (id == null || id.isEmpty) {
      final sp = await SharedPreferences.getInstance();
      id = sp.getString(_keyUserId);
    }
    return id;
  }

  // User Name
  static Future<void> setUserName(String name) async {
    await _storage.write(key: _keyUserName, value: name);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyUserName, name);
  }

  static Future<String?> getUserName() async {
    String? name = await _storage.read(key: _keyUserName);
    if (name == null || name.isEmpty) {
      final sp = await SharedPreferences.getInstance();
      name = sp.getString(_keyUserName);
    }
    return name;
  }

  // Clear all credentials
  static Future<void> clearAll() async {
    await _storage.deleteAll();
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }

  static Future<bool> containsToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

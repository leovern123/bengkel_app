import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: "token");
  }

  // Save email and password securely for biometric login
  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: "email", value: email);
    await _storage.write(key: "password", value: password);
  }

  static Future<Map<String, String>?> getCredentials() async {
    final email = await _storage.read(key: "email");
    final password = await _storage.read(key: "password");
    if (email != null && password != null) {
      return {"email": email, "password": password};
    }
    return null;
  }
}
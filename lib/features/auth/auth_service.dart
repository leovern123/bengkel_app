import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthService {
  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        "/register",
        data: {
          "name": name,
          "email": email,
          "password": password,
        },
      );
      final token = response.data['token'];
      await TokenStorage.saveToken(token);
      return true;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        "/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      final token = response.data['token'];
      await TokenStorage.saveToken(token);
      return true;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> profile() async {
    try {
      final response = await ApiClient.dio.get("/profile");
      return response.data;
    } catch (e) {
      print("PROFILE ERROR: $e");
      return null;
    }
  }

  static Future<String?> uploadAvatar(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });
      final response = await ApiClient.dio.post("/profile/avatar", data: formData);
      return response.data['avatar_url'];
    } catch (e) {
      print("UPLOAD AVATAR ERROR: $e");
      return null;
    }
  }

  static Future<bool> logout() async {
    try {
      await ApiClient.dio.post("/logout");
      await TokenStorage.deleteToken();
      return true;
    } catch (e) {
      print("LOGOUT ERROR: $e");
      return false;
    }
  }
}
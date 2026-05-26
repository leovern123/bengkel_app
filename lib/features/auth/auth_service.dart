import 'dart:io';
import 'package:flutter/foundation.dart';
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

      // Simpan user_id jika ada di response
      final userId = response.data['user']?['id'] ?? response.data['id'];
      if (userId != null) {
        await TokenStorage.saveUserId(userId is int ? userId : int.tryParse(userId.toString()) ?? 0);
      }

      return true;
    } catch (e) {
      debugPrint("REGISTER ERROR: $e");
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

      // Simpan user_id dari response login
      final userId = response.data['user']?['id'] ?? response.data['id'];
      if (userId != null) {
        await TokenStorage.saveUserId(userId is int ? userId : int.tryParse(userId.toString()) ?? 0);
      }

      return true;
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> profile() async {
    try {
      final response = await ApiClient.dio.get("/profile");

      // Simpan user_id dari profile jika belum tersimpan
      final userId = response.data['id'];
      if (userId != null) {
        final existing = await TokenStorage.getUserId();
        if (existing == null) {
          await TokenStorage.saveUserId(userId is int ? userId : int.tryParse(userId.toString()) ?? 0);
        }
      }

      return response.data;
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");
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
      debugPrint("UPLOAD AVATAR ERROR: $e");
      return null;
    }
  }

  /// Ubah password — return null jika berhasil, return pesan error jika gagal
  static Future<String?> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      return "Konfirmasi password tidak cocok.";
    }
    if (newPassword.length < 8) {
      return "Password baru minimal 8 karakter.";
    }
    try {
      await ApiClient.dio.put("/profile/password", data: {
        "current_password": oldPassword,
        "password": newPassword,
        "password_confirmation": confirmPassword,
      });
      return null; // sukses
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data?['message'] ?? e.response?.data?['error'];
        if (msg != null) return msg.toString();
      }
      debugPrint("CHANGE PASSWORD ERROR: $e");
      return "Gagal mengubah password. Periksa password lama Anda.";
    }
  }

  static Future<bool> logout() async {
    try {
      await ApiClient.dio.post("/logout");
    } catch (e) {
      // Tetap lanjut logout meskipun API error (misal: no internet)
      debugPrint("LOGOUT API ERROR (ignored): $e");
    }
    // Selalu hapus token lokal agar user bisa keluar
    await TokenStorage.deleteToken();
    return true;
  }
}
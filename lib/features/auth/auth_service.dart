import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthService {
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
}
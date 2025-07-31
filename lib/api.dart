import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Define your base URL once (e.g., from config file)
class ApiService {
  static const String baseUrl =
      // 'http://127.0.0.1:8000/';
      'http://192.168.1.17:8000/' ;// or your production URL

  Future<String> login({
    required String schoolCode,
    required String phone,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/api/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'school_code': schoolCode,
          'phone': phone,
          'password': password,
          'role' :role
        }),
      );

      print('👤 login response: ${response.body}');

      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

      if (response.statusCode == 200 && data.containsKey('token')) {
        final token = data['token']; // ✅ Token from DRF
        final userId = data['user_id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_token', token);
        await prefs.setInt('user_id', userId);

        print("✅ Stored token: $token");
        return token;
      } else {
        print(
            "⚠️ Login failed with status: ${response.statusCode}, body: ${response.body}");
      }
    } catch (e) {
      print('❗ Exception during login: $e');
    }

    return '';
  }
}

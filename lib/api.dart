import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Define your base URL once (e.g., from config file)
class ApiService {
  static const String baseUrl =
      // 'http://127.0.0.1:8000/';
      // 'http://192.168.1.17:8000';
      'https://myblogcrud.pythonanywhere.com' ; // or your production URL

  Future<Map<String, dynamic>> login({
    required String schoolCode,
    required String phone,
    required String password,
    required String role,
    String? vehicle, 
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
          'role': role,
          if (vehicle != null) 'vehicle': vehicle, // <-- include only if present

        }),
      );

      print('👤 login response: ${response.body}');

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode == 200 && data.containsKey('token')) {
        return {
          'token': data['token'].toString(),
          'user_id': data['user_id'],
          'role': data['role'].toString(),
          'name': data['name']?.toString() ?? '',
          'phone': data['phone']?.toString() ?? '',
        };
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('❗ Exception during login: $e');
      throw Exception('Login failed: $e');
    }
  }
  
  Future<Map<String, dynamic>?> fetchCurrentUser(String token) async {
  final url = Uri.parse('$baseUrl/api/user/me/'); // Replace with your actual API endpoint

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
  );

  print('📦 Response Status Code: ${response.statusCode}');
  print('📨 Response Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('✅ User data fetched: $data');
    return data;
  } else {
    print('❌ Failed to fetch user data: ${response.statusCode} - ${response.body}');
    return null;
  }
}




}

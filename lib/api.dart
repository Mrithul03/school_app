import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Define your base URL once (e.g., from config file)
class ApiService {
  static const String baseUrl =
      // 'http://127.0.0.1:8000/';
      // 'http://192.168.1.17:8000';
  'https://myblogcrud.pythonanywhere.com';
  // 'https://school-web-wfu4.onrender.com';

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
          if (vehicle != null)
            'vehicle': vehicle, // <-- include only if present
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
    final url = Uri.parse(
        '$baseUrl/api/user/me/'); // Replace with your actual API endpoint

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
      print(
          '❌ Failed to fetch user data: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>?> fetchStudentRoutes(String token, int vehicleId) async {
  final url = Uri.parse('$baseUrl/api/student_routes/$vehicleId/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
  );

  print('📦 Response routes Status Code: ${response.statusCode}');
  print('📨 Response routes Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('✅ Student routes fetched: $data');

    if (data is List) {
      return data; // Return the list of routes
    } else {
      print('⚠️ Unexpected data format (not a list)');
      return null;
    }
  } else {
    print('❌ Failed to fetch routes: ${response.statusCode} - ${response.body}');
    return null;
  }
}


  Future<Map<String, dynamic>?> fetchCurrentvehicle_location(
      String token) async {
    final url = Uri.parse(
        '$baseUrl/api/locations_list/'); // Replace with your actual API endpoint

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    print('📦 Response location_list Status Code: ${response.statusCode}');
    print('📨 Response location_list Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ User location_list fetched: $data');
      return data;
    } else {
      print(
          '❌ Failed to fetch location_list: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<bool> updateLocation(
  int studentId,
  String token,
  double lat,
  double lng,
) async {
  try {
    final url = Uri.parse('$baseUrl/api/student/$studentId/update-location/');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'home_lat': lat,
        'home_lng': lng,
      }),
    );

    print('📦 Status: ${response.statusCode}');
    print('📨 Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true; // ✅ Success
    } else {
      print('❌ Failed: ${response.body}');
      return false;
    }
  } catch (e) {
    print('⚠️ Error updating location: $e');
    return false;
  }
}



}

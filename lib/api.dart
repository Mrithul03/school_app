import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
  }
}

// ✅ Define your base URL once (e.g., from config file)
class ApiService {
  static const String baseUrl =
      // 'http://127.0.0.1:8000/';
      // 'http://192.168.1.17:8000';
      'https://myblogcrud.pythonanywhere.com';
  // 'https://school-web-wfu4.onrender.com';


  /// Register (complete setup by parent)
  static Future<Map<String, dynamic>> parentRegister({
  required String phone,
  required String password,
  required String parentName,
  required String studentName,
}) async {
  final url = Uri.parse("$baseUrl/api/parent/register/");

  final response = await http.patch(url, body: {
    "phone": phone,
    "password": password,
    "parent_name": parentName,
    "student_name": studentName,
  });

  print("🔗 API CALL: $url");
  print("📩 Status: ${response.statusCode}");
  print("📩 Response: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    // Instead of parsing HTML as JSON
    return {
      "success": false,
      "error": "Server error: ${response.statusCode}. ${response.reasonPhrase}"
    };
  }
}


Future<String?> _firebaseToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {}
    return null;
  }


  Future<Map<String, dynamic>> login({
    required String schoolCode,
    required String phone,
    required String password,
    required String role,
    String? vehicle,
  }) async {
    final url = Uri.parse('$baseUrl/api/login/');
    final fCMToken = await _firebaseToken();
    print('📲 Sending FCM Token: $fCMToken');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'school_code': schoolCode,
          'phone': phone,
          'password': password,
          'role': role,
          'fcm_device_token': fCMToken,
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
      print(
          '❌ Failed to fetch routes: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentvehicle_locationdata(
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

  Future<List<dynamic>?> fetchStudentList(String token, int vehicleId) async {
    final url = Uri.parse('$baseUrl/api/students/$vehicleId/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    print('📦 Response student list Status Code: ${response.statusCode}');
    print('📨 Response student list Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Student student list fetched: $data');

      if (data is List) {
        return data; // Return the list of routes
      } else {
        print('⚠️ Unexpected data format (not a list)');
        return null;
      }
    } else {
      print(
          '❌ Failed to fetch routes: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<bool> createPayment({
  required int studentId,
  required int month,   // 1-12
  required int year,    // add this!
  required double amount,
  required bool isPaid,
  String? paidOn,
  required String token,
}) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/api/payment/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        "student_id": studentId,
        "month": month,
        "year": year,          // send year as int
        "amount": amount,
        "is_paid": isPaid,
        "paid_on": paidOn,     // must be "YYYY-MM-DD" string or null
      }),
    );

    if (response.statusCode == 201) return true;
    print("❌ Failed: ${response.body}");
    return false;
  } catch (e) {
    print("⚠️ Error: $e");
    return false;
  }
}


  Future<List<dynamic>> getPayments(String token) async {
  final url = Uri.parse("$baseUrl/api/payment-list/");
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    },
  );

  print('📦 Response payment list Status Code: ${response.statusCode}');
  print('📨 Response payment list Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    print('✅ Student payment list fetched: $data');
    return data;
  } else {
    print('❌ Failed to fetch payment list');
    return [];
  }
}


  Future<bool> editRouteOrder(
    int routeId,
    String token,
    int newOrder,
    int newTripNumber, // ✅ added trip number
) async {
  try {
    final url = Uri.parse('$baseUrl/api/routes/$routeId/edit-route-order/');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'route_order': newOrder,
        'trip_number': newTripNumber, // ✅ send trip number to API
      }),
    );

    print('📦 Status: ${response.statusCode}');
    print('📨 Body: ${response.body}');

    return response.statusCode == 200;
  } catch (e) {
    print('⚠️ Error editing route order: $e');
    return false;
  }
}



  // Future<bool> editPayment(
  //   int paymentId,
  //   String token, {
  //   int? studentId,
  //   String? month, 
  //   String? amount,
  //   bool? isPaid,
  //   String? paidOn, 
  // }) async {
  //   try {
  //     final url = Uri.parse('$baseUrl/api/payment/$paymentId/update-payment/');

  //     // Only send fields that are not null
  //     final Map<String, dynamic> body = {};
  //     if (studentId != null) body['student_id'] = studentId;
  //     if (month != null) body['month'] = month;
  //     if (amount != null) body['amount'] = amount;
  //     if (isPaid != null) body['is_paid'] = isPaid;
  //     if (paidOn != null) body['paid_on'] = paidOn;

  //     final response = await http.patch(
  //       url,
  //       headers: {
  //         'Authorization': 'Token $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(body),
  //     );

  //     print('📦 Status: ${response.statusCode}');
  //     print('📨 Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       return true; // ✅ Successfully updated
  //     } else {
  //       print('❌ Failed: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('⚠️ Error editing payment: $e');
  //     return false;
  //   }
  // }
}

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LocationTracker {
//   final int vehicleId;
//   final String wsUrl;

//   WebSocket? _socket;
//   Timer? _backgroundTimer;

//   int _updateCount = 0;
//   int _failureCount = 0;
//   final int maxFailures = 10;

//   // 🔧 ADDED tracking flags
//   bool _isTracking = false;
//   bool _manuallyStopped = false;

//   LocationTracker({
//     required this.vehicleId,
//     // this.wsUrl = 'ws://school-web-wfu4.onrender.com/ws/location/',
//     this.wsUrl = 'ws://192.168.1.17:8000/ws/location/',
//   });

//   Future<bool> _checkPermissions() async {
//     final locationStatus = await Permission.location.request();
//     final alwaysStatus = await Permission.locationAlways.request();

//     if (!locationStatus.isGranted || !alwaysStatus.isGranted) {
//       print('❌ Location permission not granted');
//       return false;
//     }

//     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print('❌ Location services disabled.');
//       return false;
//     }

//     return true;
//   }

//   Future<void> startTracking() async {
//     if (_isTracking) return; // 🔧 prevent duplicate tracking
//     _isTracking = true;
//     _manuallyStopped = false;

//     final hasPermission = await _checkPermissions();
//     if (!hasPermission) return;

//     await _connectWebSocket();

//     _backgroundTimer?.cancel();
//     _backgroundTimer = Timer.periodic(Duration(seconds: 1), (_) async {
//       try {
//         final position = await Geolocator.getCurrentPosition();

//         _updateCount++;
//         print(
//             "📍 ($_updateCount) Sending via WebSocket: ${position.latitude}, ${position.longitude}");

//         final data = jsonEncode({
//           "latitude": position.latitude,
//           "longitude": position.longitude,
//         });

//         _socket?.add(data);
//       } catch (e) {
//         print("❌ Error getting location: $e");
//       }
//     });
//   }

//   Future<void> _connectWebSocket() async {
//     final url = '$wsUrl$vehicleId/'; // 🔧 ensure correct URL

//     try {
//       _socket = await WebSocket.connect(url);
//       print("✅ WebSocket connected to $url");

//       _socket!.listen(
//         (message) {
//           print("📩 Message from server: $message");
//         },
//         onDone: () {
//           print("⚠️ WebSocket closed.");
//           if (!_manuallyStopped) {
//             print("🔁 Reconnecting...");
//             _reconnect(); // 🔧 only reconnect if not manually stopped
//           }
//         },
//         onError: (error) {
//           print("❌ WebSocket error: $error");
//           if (!_manuallyStopped) {
//             print("🔁 Reconnecting...");
//             _reconnect(); // 🔧 only reconnect if not manually stopped
//           }
//         },
//       );
//     } catch (e) {
//       print("❌ Failed to connect WebSocket: $e");
//       if (!_manuallyStopped) {
//         print("🔁 Reconnecting...");
//         _reconnect(); // 🔧 only reconnect if not manually stopped
//       }
//     }
//   }

//   void _reconnect() {
//     Future.delayed(Duration(seconds: 3), () {
//       if (!_manuallyStopped) {
//         _connectWebSocket(); // 🔧 reconnect only if not manually stopped
//       } else {
//         print("⛔ Reconnect skipped - manually stopped.");
//       }
//     });
//   }

//   Future<void> stopTracking() async {
//     print("🛑 Stopping tracking...");

//     _manuallyStopped = true; // 🔧 prevents reconnect
//     _isTracking = false;     // 🔧 marks as no longer tracking

//     _backgroundTimer?.cancel();
//     _backgroundTimer = null;

//     await _socket?.close();
//     _socket = null;

//     print("✅ Tracking stopped.");
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationTracker {
  final int vehicleId;
  final String baseUrl;

  Timer? _backgroundTimer;
  bool _isTracking = false;

  LocationTracker({
    required this.vehicleId,
    this.baseUrl = 'https://myblogcrud.pythonanywhere.com',
  });

  /// ✅ Check location & notification permissions
  Future<bool> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final backgroundStatus = await Permission.locationAlways.status;

    if (!locationStatus.isGranted || !backgroundStatus.isGranted) {
      print("❌ Location permission not granted");
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location services disabled");
      return false;
    }

    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        print("❌ Notification permission denied");
        return false;
      }
    }

    return true;
  }

  /// 🚀 Start sending locations every X seconds
  Future<void> startTracking({String status = "start"}) async {
    if (_isTracking) {
      print("⚠️ Already tracking, skipping...");
      return;
    }

    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;

    _isTracking = true;

    // Send first location immediately
    await _sendLocationOnce(status: status);

    // Start periodic updates
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      await _sendLocationOnce(status: status);
    });

    print("✅ Tracking started...");
  }

  /// ⏹ Stop tracking and send last location
  Future<void> stopTracking({String status = "stop"}) async {
    print("🛑 Stopping tracking...");

    _isTracking = false;
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    await _sendLocationOnce(status: status);

    print("🛑 Tracking stopped, final location sent.");
  }

  /// 📡 Send one location update
  Future<void> _sendLocationOnce({String status = "start"}) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      await _sendLocationUpdate(
        latitude: position.latitude,
        longitude: position.longitude,
        status: status,
      );
    } catch (e) {
      print("❌ Failed to get location: $e");
    }
  }

  /// 🌍 API request to send location
  Future<bool> _sendLocationUpdate({
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/api/update_location/');
    final body = {
      "vehicle_id": vehicleId,
      "latitude": latitude,
      "longitude": longitude,
      "status": status,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Sent location: $latitude,$longitude [Status: $status]");
        return true;
      } else {
        print("❌ Server error: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Network error: $e");
      return false;
    }
  }
}


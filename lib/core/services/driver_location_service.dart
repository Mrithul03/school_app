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

  int _updateCount = 0;
  int _failureCount = 0;

  Timer? _backgroundTimer;
  bool _isTracking = false;
  bool _manuallyStopped = false;

  // Queue to store unsent locations
  final List<Map<String, dynamic>> _unsentQueue = [];

  LocationTracker({
    required this.vehicleId,
    this.baseUrl = 'https://myblogcrud.pythonanywhere.com',
  });

  /// Check location permissions
  Future<bool> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final backgroundStatus = await Permission.locationAlways.status;

    if (!locationStatus.isGranted || !backgroundStatus.isGranted) {
      print("❌ Location permission not granted (must be requested in foreground)");
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

  /// Start tracking location periodically
  Future<void> startTracking({String status = "start"}) async {
    print("🔄 Starting tracking for status: $status");
    if (_isTracking) {
      print("⚠️ Already tracking, skipping...");
      return;
    }

    _isTracking = true;
    _manuallyStopped = false;

    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;

    // Send first location
    await _sendLocationOnce(status: status);

    // Start periodic updates
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(Duration(seconds: 2), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition();

        _updateCount++;
        print("📍 ($_updateCount) BG Location: ${position.latitude}, ${position.longitude}");

        final locationData = {
          "latitude": position.latitude,
          "longitude": position.longitude,
          "status": status ?? "start",
        };

        _unsentQueue.add(locationData); // add to queue
        await _trySendQueue();
      } catch (e) {
        print("❌ Error getting location: $e");
      }
    });
  }

  /// Try sending all queued locations
  Future<void> _trySendQueue() async {
    for (int i = 0; i < _unsentQueue.length; i++) {
      final loc = _unsentQueue[i];
      final success = await _sendLocationUpdate(
        latitude: loc['latitude'],
        longitude: loc['longitude'],
        status: loc['status'],
      );

      if (success) {
        _unsentQueue.removeAt(i);
        i--; // adjust index after removal
      } else {
        print("⚠️ Network failed, will retry later");
        break; // stop sending, retry on next update
      }
    }
  }

  /// Send location update to server
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
        print("✅ Sent location successfully: ${response.body}");
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

  /// Send location once (e.g., at start or stop)
  Future<void> _sendLocationOnce({String status = "start"}) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final locationData = {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "status": status,
      };
      _unsentQueue.add(locationData);
      await _trySendQueue();
    } catch (e) {
      print("❌ Failed to get initial location: $e");
    }
  }

  /// Stop tracking
  Future<void> stopTracking({String status = "stop"}) async {
    print("🛑 Stopping tracking...");

    _manuallyStopped = true;
    _isTracking = false;

    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    await _sendLocationOnce(status: status);
    print("🛑 Final location sent. Tracking stopped.");
  }
}


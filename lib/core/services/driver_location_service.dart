import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationTracker {
  final int vehicleId;
  final String baseUrl;

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  int _updateCount = 0;
  int _failureCount = 0;
  final int maxFailures = 10;

  Timer? _backgroundTimer; // ✅ EDITED

  LocationTracker({
    required this.vehicleId,
    this.baseUrl = 'https://myblogcrud.pythonanywhere.com',
  });

  Future<bool> _checkPermissions() async {
    final locationStatus = await Permission.location.request();
    final alwaysStatus = await Permission.locationAlways.request();

    if (!locationStatus.isGranted || !alwaysStatus.isGranted) {
      print('❌ Location permission not granted');
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services disabled.');
      return false;
    }

    return true;
  }

  Future<void> startTracking({String status = "start"}) async {
    print("🔄 Starting tracking for status: $status");

    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;

    await _sendLocationOnce(status: status);

    // ✅ EDITED: Use Timer instead of StreamSubscription for background safety
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        _updateCount++;
        print("📍 ($_updateCount) BG Location: ${position.latitude}, ${position.longitude}");

        final success = await _sendLocationUpdate(
          latitude: position.latitude,
          longitude: position.longitude,
          status: status,
        );

        if (!success) {
          _failureCount++;
          print("⚠️ ($_failureCount/$maxFailures) Failed update");
          if (_failureCount >= maxFailures) {
            await stopTracking(status: "stop");
            print("❌ Too many failures, auto-stopping tracking");
          }
        } else {
          _failureCount = 0;
        }
      } catch (e) {
        print("❌ BG location error: $e");
      }
    });

    print("🚚 Background location tracking started.");
  }

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

  Future<void> _sendLocationOnce({String status = "start"}) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      await _sendLocationUpdate(
        latitude: position.latitude,
        longitude: position.longitude,
        status: status,
      );
    } catch (e) {
      print("❌ Failed to get initial location: $e");
    }
  }

  Future<void> stopTracking({String status = "stop"}) async {
    print("🛑 Stopping tracking...");

    // ✅ EDITED: Stop Timer
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    await _sendLocationOnce(status: status);
    print("🛑 Final location sent. Tracking stopped.");
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart'; // ✅

class LocationTracker {
  final int vehicleId;
  final String baseUrl;
  StreamSubscription<Position>? _positionStream;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(); // ✅

  int _updateCount = 0;
  int _failureCount = 0;
  final int maxFailures = 10;

  LocationTracker({
    required this.vehicleId,
    // this.baseUrl = 'http://192.168.1.17:8000',
    this.baseUrl = 'https://myblogcrud.pythonanywhere.com'
    
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

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (Position position) async {
        _updateCount++;
        print("📍 ($_updateCount) Location: ${position.latitude}, ${position.longitude}");

        final success = await _sendLocationUpdate(
          latitude: position.latitude,
          longitude: position.longitude,
          status: status,
        );

        if (!success) {
          _failureCount++;
          if (_failureCount >= maxFailures) {
            await stopTracking(status: "stop");
            print("❌ Too many failures, auto-stopping tracking");
          }
        } else {
          _failureCount = 0;
        }
      },
      onError: (error) {
        print("⚠️ Location stream error: $error");
      },
      cancelOnError: false,
    );

    print("🚚 Location tracking started.");
  }

  Future<bool> _sendLocationUpdate({
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final data = {
        "vehicle_id": vehicleId,
        "latitude": latitude,
        "longitude": longitude,
        "status": status,
        "timestamp": timestamp,
      };

      await _dbRef.child('vehicle_locations/$vehicleId').push().set(data); // ✅

      print("✅ Firebase location update: $data");
      return true;
    } catch (e) {
      print("❌ Firebase error: $e");
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
    await _positionStream?.cancel();
    _positionStream = null;

    await _sendLocationOnce(status: status);
    print("🛑 Tracking stopped and final location sent.");
  }
}

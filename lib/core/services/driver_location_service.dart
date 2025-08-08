import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationTracker {
  final int vehicleId;
  final String wsUrl;

  WebSocket? _socket;
  Timer? _backgroundTimer;

  int _updateCount = 0;
  int _failureCount = 0;
  final int maxFailures = 10;

  // 🔧 ADDED tracking flags
  bool _isTracking = false;
  bool _manuallyStopped = false;

  LocationTracker({
    required this.vehicleId,
    this.wsUrl = 'ws://192.168.1.17:8000/ws/location/',
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

  Future<void> startTracking() async {
    if (_isTracking) return; // 🔧 prevent duplicate tracking
    _isTracking = true;
    _manuallyStopped = false;

    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;

    await _connectWebSocket();

    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition();

        _updateCount++;
        print(
            "📍 ($_updateCount) Sending via WebSocket: ${position.latitude}, ${position.longitude}");

        final data = jsonEncode({
          "latitude": position.latitude,
          "longitude": position.longitude,
        });

        _socket?.add(data);
      } catch (e) {
        print("❌ Error getting location: $e");
      }
    });
  }

  Future<void> _connectWebSocket() async {
    final url = '$wsUrl$vehicleId/'; // 🔧 ensure correct URL

    try {
      _socket = await WebSocket.connect(url);
      print("✅ WebSocket connected to $url");

      _socket!.listen(
        (message) {
          print("📩 Message from server: $message");
        },
        onDone: () {
          print("⚠️ WebSocket closed.");
          if (!_manuallyStopped) {
            print("🔁 Reconnecting...");
            _reconnect(); // 🔧 only reconnect if not manually stopped
          }
        },
        onError: (error) {
          print("❌ WebSocket error: $error");
          if (!_manuallyStopped) {
            print("🔁 Reconnecting...");
            _reconnect(); // 🔧 only reconnect if not manually stopped
          }
        },
      );
    } catch (e) {
      print("❌ Failed to connect WebSocket: $e");
      if (!_manuallyStopped) {
        print("🔁 Reconnecting...");
        _reconnect(); // 🔧 only reconnect if not manually stopped
      }
    }
  }

  void _reconnect() {
    Future.delayed(Duration(seconds: 3), () {
      if (!_manuallyStopped) {
        _connectWebSocket(); // 🔧 reconnect only if not manually stopped
      } else {
        print("⛔ Reconnect skipped - manually stopped.");
      }
    });
  }

  Future<void> stopTracking() async {
    print("🛑 Stopping tracking...");

    _manuallyStopped = true; // 🔧 prevents reconnect
    _isTracking = false;     // 🔧 marks as no longer tracking

    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    await _socket?.close();
    _socket = null;

    print("✅ Tracking stopped.");
  }
}

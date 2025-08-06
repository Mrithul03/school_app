import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (!(await Geolocator.isLocationServiceEnabled())) return;

    final position = await Geolocator.getCurrentPosition();
    final latitude = position.latitude;
    final longitude = position.longitude;

    // 🔁 Replace with your API endpoint and device/vehicle ID
    await http.post(
      Uri.parse('https://myblogcrud.pythonanywhere.com/api/send_location/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "vehicle_id": 123, // pass dynamically if needed
        "lat": latitude,
        "lng": longitude,
      }),
    );
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

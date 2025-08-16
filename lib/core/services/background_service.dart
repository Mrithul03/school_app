import 'package:flutter_background_service/flutter_background_service.dart';
import 'driver_location_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  LocationTracker? tracker;

  service.on('start-tracking').listen((event) {
    final vehicleId = event?['vehicle_id'] ?? 0;
    final status = event?['status'] ?? 'start';

    tracker = LocationTracker(vehicleId: vehicleId);
    tracker!.startTracking(status: status);

    print("🟢 LocationTracker started for vehicleId: $vehicleId, status: $status");
  });

  service.on('stop-tracking').listen((event) {
    final status = event?['status'] ?? 'stop';
    tracker?.stopTracking(status: status);
    print("🔴 LocationTracker stopped with status: $status");
  });
}

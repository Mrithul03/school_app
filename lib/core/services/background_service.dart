import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'driver_location_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  LocationTracker? tracker;

  // ✅ Show foreground notification (Required for background location updates)
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Location Tracking",
      content: "Tracking vehicle location in background...",
    );
  }

  // ✅ Handle start-tracking event
  service.on('start-tracking').listen((event) {
    final vehicleId = event?['vehicle_id'] ?? 0;
    final status = event?['status'] ?? 'start';

    tracker = LocationTracker(vehicleId: vehicleId);
    tracker!.startTracking(status: status);

    print("🟢 LocationTracker started for vehicleId: $vehicleId, status: $status");
  });

  // ✅ Handle stop-tracking event
  service.on('stop-tracking').listen((event) {
    final status = event?['status'] ?? 'stop';
    tracker?.stopTracking(status: status);

    print("🔴 LocationTracker stopped with status: $status");

    // ✅ Stop foreground service when tracking ends
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Location Tracking",
        content: "Stopped.",
      );
      service.stopSelf();
    }
  });
}

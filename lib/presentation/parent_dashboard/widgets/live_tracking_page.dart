import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LiveTrackingPage extends StatefulWidget {
  final int vehicleId;

  const LiveTrackingPage({required this.vehicleId, Key? key}) : super(key: key);

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _driverLocation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchDriverLocation(); // Initial fetch
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchDriverLocation());
  }

  Future<void> _fetchDriverLocation() async {
    final url = Uri.parse("https://yourbackend.com/api/vehicle/${widget.vehicleId}/location/");
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lat = data['latitude'];
        final lng = data['longitude'];

        final newLocation = LatLng(lat, lng);

        if (_driverLocation != newLocation) {
          setState(() {
            _driverLocation = newLocation;
          });

          final controller = await _mapController.future;
          controller.animateCamera(CameraUpdate.newLatLng(newLocation));
        }
      } else {
        print("❌ Failed to get location: ${response.statusCode}");
      }
    } catch (e) {
      print("❗ Error fetching location: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking")),
      body: _driverLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _driverLocation!,
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("driver"),
                  position: _driverLocation!,
                  infoWindow: const InfoWindow(title: "Driver Location"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                ),
              },
              onMapCreated: (controller) {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                }
              },
            ),
    );
  }
}

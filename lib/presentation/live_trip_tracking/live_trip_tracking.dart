// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class LiveTripTrackingScreen extends StatefulWidget {
//   final int vehicleId;

//   const LiveTripTrackingScreen({Key? key, required this.vehicleId}) : super(key: key);

//   @override
//   _LiveTripTrackingPageState createState() => _LiveTripTrackingPageState();
// }

// class _LiveTripTrackingPageState extends State<LiveTripTrackingScreen> {
//   GoogleMapController? _mapController;
//   LatLng? _vehiclePosition;
//   Timer? _pollingTimer;

//   @override
//   void initState() {
//     super.initState();
//     _startPolling();
//   }

//   /// Start polling vehicle location every 10 seconds
//   void _startPolling() {
//     _fetchVehicleLocation(); // Fetch once initially
//     _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
//       _fetchVehicleLocation();
//     });
//   }

//   /// Fetch vehicle location from backend API
//   Future<void> _fetchVehicleLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('device_token') ?? '';

//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.1.17:8000/api/vehicle/${widget.vehicleId}/location'),
//         headers: {
//           'Authorization': 'Token $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final lat = double.tryParse(data['latitude'].toString());
//         final lng = double.tryParse(data['longitude'].toString());

//         if (lat != null && lng != null) {
//           final newPosition = LatLng(lat, lng);
//           setState(() {
//             _vehiclePosition = newPosition;
//           });

//           // Move the camera to new position if map is ready
//           if (_mapController != null) {
//             _mapController!.animateCamera(
//               CameraUpdate.newLatLng(newPosition),
//             );
//           }
//         } else {
//           print('❌ Invalid latitude or longitude data received');
//         }
//       } else {
//         print('❌ Failed to fetch location: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('⚠ Error fetching location: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     _mapController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Trip Tracking'),
//       ),
//       body: _vehiclePosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _vehiclePosition!,
//                 zoom: 15,
//               ),
//               markers: {
//                 Marker(
//                   markerId: const MarkerId('vehicle'),
//                   position: _vehiclePosition!,
//                   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//                   infoWindow: const InfoWindow(title: 'Vehicle Location'),
//                 ),
//               },
//               onMapCreated: (controller) {
//                 _mapController = controller;
//               },
//             ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LiveTripTrackingScreen extends StatefulWidget {
  final int vehicleId;

  const LiveTripTrackingScreen({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _LiveTripTrackingPageState createState() => _LiveTripTrackingPageState();
}

class _LiveTripTrackingPageState extends State<LiveTripTrackingScreen> {
  Timer? _pollingTimer;
  double? _latitude;
  double? _longitude;
  String _status = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _fetchVehicleLocation(); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchVehicleLocation();
    });
  }

  Future<void> _fetchVehicleLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.17:8000/api/vehicle/${widget.vehicleId}/location'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lat = double.tryParse(data['latitude'].toString());
        final lng = double.tryParse(data['longitude'].toString());

        if (lat != null && lng != null) {
          setState(() {
            _latitude = lat;
            _longitude = lng;
            _status = 'Location fetched successfully!';
          });
        } else {
          setState(() {
            _status = 'Invalid coordinates received';
          });
        }
      } else {
        setState(() {
          _status = 'Failed to fetch location: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Location')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _latitude == null || _longitude == null
              ? Text(_status)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Latitude: $_latitude', style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    Text('Longitude: $_longitude', style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 20),
                    Text(_status, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }
}

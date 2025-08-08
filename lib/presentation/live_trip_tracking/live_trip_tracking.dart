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
//   Timer? _pollingTimer;
//   LatLng? _currentPosition;
//   String _status = 'Fetching location...';

//   late GoogleMapController _mapController;

//   @override
//   void initState() {
//     super.initState();
//     _startPolling();
//   }

//   void _startPolling() {
//     _fetchVehicleLocation(); // Initial fetch
//     _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _fetchVehicleLocation();
//     });
//   }

//   Future<void> _fetchVehicleLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('device_token') ?? '';

//     try {
//       final response = await http.get(
//         Uri.parse('https://myblogcrud.pythonanywhere.com/api/vehicle/${widget.vehicleId}/location'),
//         //  Uri.parse('https://myblogcrud.pythonanywhere.com/api/vehicle/${widget.vehicleId}/location'),
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
//             _currentPosition = newPosition;
//             _status = 'Location fetched successfully!';
//           });

//           _mapController.animateCamera(
//             CameraUpdate.newLatLng(newPosition),
//           );
//         } else {
//           setState(() {
//             _status = 'Invalid coordinates received';
//           });
//         }
//       } else {
//         setState(() {
//           _status = 'Failed to fetch location: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _status = 'Error: $e';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Live Vehicle Tracking')),
//       body: _currentPosition == null
//           ? Center(child: Text(_status))
//           : GoogleMap(
//               onMapCreated: (controller) => _mapController = controller,
//               initialCameraPosition: CameraPosition(
//                 target: _currentPosition!,
//                 zoom: 16,
//               ),
//               markers: {
//                 Marker(
//                   markerId: const MarkerId('vehicle'),
//                   position: _currentPosition!,
//                   infoWindow: const InfoWindow(title: 'Vehicle Location'),
//                 ),
//               },
//             ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LiveTripTrackingScreen extends StatefulWidget {
  final int vehicleId;

  const LiveTripTrackingScreen({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _LiveTripTrackingPageState createState() => _LiveTripTrackingPageState();
}

class _LiveTripTrackingPageState extends State<LiveTripTrackingScreen> {
  late GoogleMapController _mapController;
  Marker? _vehicleMarker;
  LatLng? _lastPosition;
  bool _mapInitialized = false;

  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void _connectWebSocket() {
    final wsUrl = 'ws://192.168.1.17:8000/ws/location/${widget.vehicleId}/'; // or use wss://yourdomain when deployed
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen((message) {
      print("📩 WebSocket message: $message");

      final data = jsonDecode(message);
      final lat = data['latitude'];
      final lng = data['longitude'];

      if (lat != null && lng != null) {
        final newPosition = LatLng(lat, lng);

        if (_lastPosition == null || _lastPosition != newPosition) {
          setState(() {
            _vehicleMarker = Marker(
              markerId: const MarkerId("vehicle"),
              position: newPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            );
            _lastPosition = newPosition;
          });

          if (_mapInitialized) {
            _animateTo(newPosition);
          }
        }
      }
    }, onError: (error) {
      print("❌ WebSocket error: $error");
    }, onDone: () {
      print("⚠️ WebSocket closed.");
    });
  }

  void _animateTo(LatLng target) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 16.5,
          tilt: 50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Trip Tracking'),
      ),
      body: _lastPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _lastPosition!,
                zoom: 16.5,
              ),
              markers: _vehicleMarker != null ? {_vehicleMarker!} : {},
              onMapCreated: (controller) {
                _mapController = controller;
                _mapInitialized = true;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}


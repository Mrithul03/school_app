import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

class TripMapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tripRoutes;
  final int tripNumber;
  final String shift;

  const TripMapScreen({
    super.key,
    required this.tripRoutes,
    required this.tripNumber,
    required this.shift,
  });

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  Future<BitmapDescriptor> _createCustomMarker(String text) async {
    final int size = 120;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = Colors.blue;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw circle
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2.0,
      paint,
    );

    // Draw text
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size / 3,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final ui.Image img =
        await recorder.endRecording().toImage(size, size); // final image
    final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  void _addMarkers() {
    // Sort by route_order
    widget.tripRoutes.sort((a, b) {
      final orderA = int.tryParse(a['route_order'].toString()) ?? 0;
      final orderB = int.tryParse(b['route_order'].toString()) ?? 0;
      return orderA.compareTo(orderB);
    });

    for (var route in widget.tripRoutes) {
      final lat = double.tryParse(route['hom_lat'].toString());
      final lng = double.tryParse(route['hom_lng'].toString());
      final name = route['student_name'] ?? 'Unknown';
      final order = route['route_order']?.toString() ?? '';

      if (lat != null && lng != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('$order-$name'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: '$order. $name'),
            // Use default marker color
          ),
        );
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.tripRoutes.isNotEmpty
        ? LatLng(
            double.parse(widget.tripRoutes[0]['hom_lat'].toString()),
            double.parse(widget.tripRoutes[0]['hom_lng'].toString()),
          )
        : const LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.shift[0].toUpperCase()}${widget.shift.substring(1)} Trip ${widget.tripNumber}'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 14,
        ),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
}

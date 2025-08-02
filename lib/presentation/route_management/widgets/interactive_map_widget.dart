import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InteractiveMapWidget extends StatefulWidget {
  final List<Map<String, dynamic>> routeStops;
  final bool isEditing;
  final Function(Map<String, dynamic>) onAddStop;
  final Function(int, Map<String, dynamic>) onEditStop;
  final VoidCallback onNavigate;
  final bool showTrafficWarnings;

  const InteractiveMapWidget({
    super.key,
    required this.routeStops,
    required this.isEditing,
    required this.onAddStop,
    required this.onEditStop,
    required this.onNavigate,
    this.showTrafficWarnings = false,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  double _currentZoom = 14.0;
  bool _showTraffic = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Container (Simulated map view)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFF0F8FF),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Stack(
            children: [
              // Background grid pattern to simulate map
              CustomPaint(
                size: Size.infinite,
                painter: MapGridPainter(),
              ),
              // Route path
              CustomPaint(
                size: Size.infinite,
                painter: RoutePathPainter(
                  stops: widget.routeStops,
                  showTraffic: widget.showTrafficWarnings,
                ),
              ),
              // Stop markers
              ...widget.routeStops.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> stop = entry.value;
                return Positioned(
                  left: (stop['mapX'] as double) * 80.w,
                  top: (stop['mapY'] as double) * 60.h,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.isEditing) {
                        widget.onEditStop(index, stop);
                      }
                    },
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _getStopColor(stop),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              // Traffic warnings overlay
              if (widget.showTrafficWarnings)
                Positioned(
                  top: 15.h,
                  right: 5.w,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Traffic Delay: +15 min',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Map controls overlay
        Positioned(
          top: 2.h,
          right: 2.w,
          child: Column(
            children: [
              // Zoom controls
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentZoom = (_currentZoom + 1).clamp(10.0, 20.0);
                        });
                      },
                      icon: CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 30,
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentZoom = (_currentZoom - 1).clamp(10.0, 20.0);
                        });
                      },
                      icon: CustomIconWidget(
                        iconName: 'remove',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              // Traffic toggle
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showTraffic = !_showTraffic;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: 'traffic',
                    color: _showTraffic
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Navigate button
        Positioned(
          bottom: 2.h,
          right: 2.w,
          child: FloatingActionButton(
            onPressed: widget.onNavigate,
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            child: CustomIconWidget(
              iconName: 'navigation',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStopColor(Map<String, dynamic> stop) {
    String status = stop['status'] ?? 'pending';
    switch (status) {
      case 'completed':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'current':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'delayed':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return Colors.grey;
    }
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Draw grid lines
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePathPainter extends CustomPainter {
  final List<Map<String, dynamic>> stops;
  final bool showTraffic;

  RoutePathPainter({required this.stops, required this.showTraffic});

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.length < 2) return;

    final paint = Paint()
      ..color = showTraffic ? Colors.red : Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Start from first stop
    final firstStop = stops.first;
    path.moveTo(
      (firstStop['mapX'] as double) * size.width,
      (firstStop['mapY'] as double) * size.height,
    );

    // Draw lines to subsequent stops
    for (int i = 1; i < stops.length; i++) {
      final stop = stops[i];
      path.lineTo(
        (stop['mapX'] as double) * size.width,
        (stop['mapY'] as double) * size.height,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

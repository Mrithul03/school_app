import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_stop_dialog_widget.dart';
import './widgets/floating_action_buttons_widget.dart';
import './widgets/interactive_map_widget.dart';
import './widgets/route_details_sheet_widget.dart';
import './widgets/route_header_widget.dart';

class RouteManagement extends StatefulWidget {
  const RouteManagement({super.key});

  @override
  State<RouteManagement> createState() => _RouteManagementState();
}

class _RouteManagementState extends State<RouteManagement> {
  String _selectedRoute = 'Route A - Morning';
  bool _isEditing = false;
  bool _showTrafficWarnings = true;

  final List<String> _availableRoutes = [
    'Route A - Morning',
    'Route A - Evening',
    'Route B - Morning',
    'Route B - Evening',
    'Route C - Morning',
    'Route C - Evening',
  ];

  final Map<String, dynamic> _routeInfo = {
    'totalDistance': '12.5 km',
    'estimatedTime': '45 min',
    'vehicleNumber': 'BUS-001',
    'driverName': 'John Smith',
  };

  List<Map<String, dynamic>> _routeStops = [
    {
      'address': '123 Oak Street, Springfield',
      'timeWindow': '7:45-7:50 AM',
      'students': ['Emma Johnson', 'Liam Smith'],
      'notes': 'Ring doorbell twice',
      'status': 'completed',
      'mapX': 0.2,
      'mapY': 0.3,
    },
    {
      'address': '456 Maple Avenue, Springfield',
      'timeWindow': '7:55-8:00 AM',
      'students': ['Olivia Brown'],
      'notes': '',
      'status': 'current',
      'mapX': 0.4,
      'mapY': 0.5,
    },
    {
      'address': '789 Pine Road, Springfield',
      'timeWindow': '8:05-8:10 AM',
      'students': ['Noah Davis', 'Ava Wilson'],
      'notes': 'Parent will be waiting outside',
      'status': 'pending',
      'mapX': 0.6,
      'mapY': 0.4,
    },
    {
      'address': '321 Elm Drive, Springfield',
      'timeWindow': '8:15-8:20 AM',
      'students': ['William Miller'],
      'notes': '',
      'status': 'delayed',
      'mapX': 0.7,
      'mapY': 0.6,
    },
    {
      'address': '654 Cedar Lane, Springfield',
      'timeWindow': '8:25-8:30 AM',
      'students': ['Sophia Garcia', 'James Rodriguez'],
      'notes': 'Use side entrance',
      'status': 'pending',
      'mapX': 0.8,
      'mapY': 0.3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Management'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showRouteOptimizationDialog,
            icon: CustomIconWidget(
              iconName: 'route',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'emergency_override',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Emergency Override'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'vehicle_info',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'directions_bus',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Vehicle Info'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'settings',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Route selection header
              RouteHeaderWidget(
                selectedRoute: _selectedRoute,
                availableRoutes: _availableRoutes,
                onRouteChanged: _onRouteChanged,
                isEditing: _isEditing,
                onToggleEdit: _toggleEditMode,
                onSaveRoute: _saveRoute,
              ),
              // Interactive map
              Expanded(
                child: GestureDetector(
                  onLongPress: _isEditing ? _showAddStopDialog : null,
                  child: InteractiveMapWidget(
                    routeStops: _routeStops,
                    isEditing: _isEditing,
                    onAddStop: _addStop,
                    onEditStop: _editStop,
                    onNavigate: _startNavigation,
                    showTrafficWarnings: _showTrafficWarnings,
                  ),
                ),
              ),
            ],
          ),
          // Route details bottom sheet
          RouteDetailsSheetWidget(
            routeInfo: _routeInfo,
            stops: _routeStops,
            isEditing: _isEditing,
            onReorderStops: _reorderStops,
            onEditStopTime: _editStopTime,
            onAddStopNote: _addStopNote,
            onSkipStop: _skipStop,
            onContactParents: _contactParents,
            onShareRoute: _shareRoute,
          ),
          // Floating action buttons
          FloatingActionButtonsWidget(
            onNavigate: _startNavigation,
            onSaveRoute: _saveRoute,
            onShareRoute: _shareRoute,
            isEditing: _isEditing,
          ),
        ],
      ),
    );
  }

  void _onRouteChanged(String newRoute) {
    setState(() {
      _selectedRoute = newRoute;
      _isEditing = false;
    });
    _loadRouteData(newRoute);
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveRoute() {
    // Save route changes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Route saved successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
    setState(() {
      _isEditing = false;
    });
  }

  void _loadRouteData(String routeName) {
    // Mock loading different route data
    // In real app, this would fetch from API/database
  }

  void _addStop(Map<String, dynamic> newStop) {
    setState(() {
      _routeStops.add(newStop);
    });
  }

  void _editStop(int index, Map<String, dynamic> stop) {
    // Show edit dialog or navigate to edit screen
    _showEditStopDialog(index, stop);
  }

  void _reorderStops(List<Map<String, dynamic>> reorderedStops) {
    setState(() {
      _routeStops = reorderedStops;
    });
  }

  void _editStopTime(int index, String newTime) {
    setState(() {
      _routeStops[index]['timeWindow'] = newTime;
    });
  }

  void _addStopNote(int index, String note) {
    setState(() {
      _routeStops[index]['notes'] = note;
    });
  }

  void _skipStop(int index) {
    setState(() {
      _routeStops[index]['status'] = 'skipped';
    });
    _notifyParentsOfSkip(index);
  }

  void _contactParents(int index) {
    final stop = _routeStops[index];
    final students = stop['students'] as List<String>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Parents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Students at this stop:'),
            SizedBox(height: 1.h),
            ...students
                .map((student) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.5.h),
                      child: Row(
                        children: [
                          Text('• $student'),
                          Spacer(),
                          IconButton(
                            onPressed: () => _callParent(student),
                            icon: CustomIconWidget(
                              iconName: 'phone',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _messageParent(student),
                            icon: CustomIconWidget(
                              iconName: 'message',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareRoute() {
    // Share route with administration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Route shared with administration'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _startNavigation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Navigation'),
        content: Text('Open preferred navigation app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openNavigationApp();
            },
            child: Text('Open Maps'),
          ),
        ],
      ),
    );
  }

  void _openNavigationApp() {
    // Open external navigation app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening navigation app...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _showAddStopDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStopDialogWidget(
        onAddStop: _addStop,
      ),
    );
  }

  void _showEditStopDialog(int index, Map<String, dynamic> stop) {
    // Show edit dialog for existing stop
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Stop'),
        content: Text('Edit functionality for ${stop['address']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRouteOptimizationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'route',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Route Optimization'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suggested improvements:'),
            SizedBox(height: 2.h),
            _buildOptimizationSuggestion(
              'Reorder stops 3 & 4',
              'Save 5 minutes',
              Icons.swap_horiz,
            ),
            _buildOptimizationSuggestion(
              'Avoid Main Street',
              'Heavy traffic detected',
              Icons.traffic,
            ),
            _buildOptimizationSuggestion(
              'Alternative route available',
              'Save 2.3 km',
              Icons.alt_route,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyOptimizations();
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationSuggestion(
      String title, String subtitle, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.lightTheme.colorScheme.primary, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyOptimizations() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Route optimizations applied'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'emergency_override':
        _showEmergencyOverrideDialog();
        break;
      case 'vehicle_info':
        _showVehicleInfoDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showEmergencyOverrideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Emergency Override'),
          ],
        ),
        content: Text(
          'This will allow route deviation and automatically notify parents and administration. Use only in emergency situations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _activateEmergencyOverride();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _showVehicleInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vehicle Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Vehicle Number', 'BUS-001'),
            _buildInfoRow('Driver', 'John Smith'),
            _buildInfoRow('Capacity', '45 students'),
            _buildInfoRow('Fuel Level', '85%'),
            _buildInfoRow('Last Maintenance', '2025-01-15'),
            _buildInfoRow('Next Service', '2025-02-15'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Route Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Show Traffic Warnings'),
              value: _showTrafficWarnings,
              onChanged: (value) {
                setState(() {
                  _showTrafficWarnings = value;
                });
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: Text('Auto-optimize Route'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text('Offline Map Cache'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _activateEmergencyOverride() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Emergency override activated. Parents and admin notified.'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _notifyParentsOfSkip(int index) {
    final stop = _routeStops[index];
    final students = stop['students'] as List<String>;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parents of ${students.join(', ')} notified of skip'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _callParent(String student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling parent of $student...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _messageParent(String student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending message to parent of $student...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }
}

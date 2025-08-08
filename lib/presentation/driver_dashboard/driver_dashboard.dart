import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
// import './widgets/active_trip_status.dart';
import './widgets/emergency_contact_dialog.dart';
import './widgets/quick_actions_bar.dart';
import './widgets/shift_status_card.dart';
import './widgets/student_card.dart';

import '../../core/services/driver_location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/api.dart';

class DriverDashboard extends StatefulWidget {
  final int vehicleId;
  const DriverDashboard({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMorningShiftActive = false;
  bool _isEveningShiftActive = false;
  bool _isOnTrip = false;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> childrenData = [];
  List<dynamic> _routes = [];
  // Map<String, dynamic>? routes;

  int? vehicleId;
  late LocationTracker _tracker;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _tracker = LocationTracker(vehicleId: widget.vehicleId);
    _tabController = TabController(length: 4, vsync: this);
    _loadUser();
    _loadRoutes();
  }

  void _startTracking(String shiftType) {
    print("🔄 Start tracking for $shiftType shift");

    // Optionally send vehicle ID, shift type, timestamp
    _tracker.startTracking(); // Implement actual tracking logic here

    setState(() {
      _isTracking = true;
    });
  }

  void _stopTracking(String shiftType) async {
    print("🛑 Stop tracking for $shiftType shift");

    await _tracker.stopTracking();

    setState(() {
      _isTracking = false;
    });

    print("✅ Tracking stopped.");
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token');

    if (token != null && token.isNotEmpty) {
      final api = ApiService();
      final data = await api.fetchCurrentUser(token);
      print('LoadUserData:$data');

      if (data != null) {
        setState(() {
          _students = [
            {
              'status': 'Running', // or from API if available
              'driver': data['vehicle']?['driver'],
              'vehicle_number': data['vehicle']?['vehicle_number'],
              'student_name': data['student']?['name'],
              'parent': data['student']?['parent'],
              'school': data['school']?['name'],
            }
          ];
          childrenData = [
            {
              'status': 'Running', // or from API if available
              'driver': data['vehicle']?['driver'],
              'vehicle_number': data['vehicle']?['vehicle_number'],
              'student_name': data['student']?['name'],
            }
          ];

          print('studentdatata:$_students');
          print('currentTripData:$childrenData');
        });
      }
    }
  }

  Future<void> _loadRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('device_token');
      if (token != null) {
        final routes = await ApiService.fetchStudentRoutes(token);
        print('routes$routes');
        if (routes != null) {
          setState(() {
            _routes = routes;
          });
        }
      }
    } catch (e) {
      print("❌ Error loading student routes: $e");
    }
  }

  // Mock emergency contacts
  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      "name": "Springfield Elementary School",
      "type": "School",
      "phone": "+1 (555) 100-2000"
    },
    {"name": "Emergency Services", "type": "Police", "phone": "911"},
    {
      "name": "School Transportation Office",
      "type": "School",
      "phone": "+1 (555) 100-2001"
    },
    {"name": "Medical Emergency", "type": "Medical", "phone": "911"}
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Driver Dashboard',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showNotifications(),
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: Colors.white,
                  size: 6.w,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 2.5.w,
                    height: 2.5.w,
                    decoration: BoxDecoration(
                      color: AppTheme.getWarningColor(true),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle:
              AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'today',
                color: Colors.white,
                size: 5.w,
              ),
              text: 'Today',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'group',
                color: Colors.white,
                size: 5.w,
              ),
              text: 'Students',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'route',
                color: Colors.white,
                size: 5.w,
              ),
              text: 'Routes',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                color: Colors.white,
                size: 5.w,
              ),
              text: 'Profile',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildStudentsTab(),
          _buildRoutesTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // 🚍 Morning Shift Card
            ShiftStatusCard(
              shiftType: 'Morning',
              isActive: _isMorningShiftActive,
              onStartTrip: () {
                _toggleShift('morning', true);
                _startTracking('morning');
              },
              onEndTrip: () {
                _toggleShift('morning', false);
                _stopTracking('morning');
              },
            ),

            // 🌙 Evening Shift Card
            ShiftStatusCard(
              shiftType: 'Evening',
              isActive: _isEveningShiftActive,
              onStartTrip: () {
                _toggleShift('evening', true);
                _startTracking('evening');
              },
              onEndTrip: () {
                _toggleShift('evening', false);
                _stopTracking('eveing');
              },
            ),

            // ⚙️ Quick Actions
            QuickActionsBar(
              onNavigationTap: _openNavigation,
              onEmergencyTap: _showEmergencyContacts,
              onRefreshTap: _refreshData,
              onSettingsTap: _openSettings,
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            color: AppTheme.lightTheme.colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Students: ${_students.length}',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Present: ${_students.where((s) => s['isPresent'] == true).length} | Absent: ${_students.where((s) => s['isPresent'] == false).length}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Swipe right to mark present',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return StudentCard(
                  student: _students[index],
                  onToggleStatus: () => _toggleStudentStatus(index),
                  onMarkPresent: () => _markStudentPresent(index),
                  onMarkAbsent: () => _markStudentAbsent(index),
                  onContactParent: () => _contactParent(_students[index]),
                  onViewNotes: () => _viewStudentNotes(_students[index]),
                  onEmergencyContact: () => _showEmergencyContacts(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesTab() {
    final Map<String, Map<int, List<Map<String, dynamic>>>> groupedRoutes = {
      'morning': {},
      'evening': {},
    };

    for (var route in _routes) {
      final shift = route['shift']?.toLowerCase();
      final tripNumber = route['trip_number'] ?? 1;

      if (shift == 'morning' || shift == 'evening') {
        groupedRoutes[shift]![tripNumber] ??= [];
        groupedRoutes[shift]![tripNumber]!.add(route);
      }
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          if (groupedRoutes['morning']!.isNotEmpty) ...[
            Text(
              'Morning Trips',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            for (var tripEntry in groupedRoutes['morning']!.entries) ...[
              Text(
                'Trip ${tripEntry.key}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 1.h),
              for (var route in tripEntry.value) ...[
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student: ${route['student_name']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('School: ${route['school']}'),
                        Text('Location: ${route['location_name']}'),
                        Text(
                            'Lat: ${route['latitude']}, Lng: ${route['longitude']}'),
                        Text('Pickup Time: ${route['pickup_time'] ?? 'N/A'}'),
                        Text('Driver: ${route['driver']}'),
                        Text('Vehicle No: ${route['vehicle_number']}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
              ],
            ],
          ],
          if (groupedRoutes['evening']!.isNotEmpty) ...[
            Text(
              'Evening Trips',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            for (var tripEntry in groupedRoutes['evening']!.entries) ...[
              Text(
                'Trip ${tripEntry.key}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 1.h),
              for (var route in tripEntry.value) ...[
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student: ${route['student_name']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('School: ${route['school']}'),
                        Text('Location: ${route['location_name']}'),
                        Text(
                            'Lat: ${route['latitude']}, Lng: ${route['longitude']}'),
                        Text('Pickup Time: ${route['pickup_time'] ?? 'N/A'}'),
                        Text('Driver: ${route['driver']}'),
                        Text('Vehicle No: ${route['vehicle_number']}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.w),
                    child: CustomImageWidget(
                      imageUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
                      width: 25.w,
                      height: 25.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Robert Johnson',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Professional School Bus Driver',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'License: CDL-A • Exp: 12/2025',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.getSuccessColor(true),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          _buildProfileOption(
            icon: 'settings',
            title: 'Settings',
            subtitle: 'App preferences and notifications',
            onTap: _openSettings,
          ),
          _buildProfileOption(
            icon: 'history',
            title: 'Trip History',
            subtitle: 'View past trips and reports',
            onTap: _viewTripHistory,
          ),
          _buildProfileOption(
            icon: 'help',
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: _showHelp,
          ),
          _buildProfileOption(
            icon: 'logout',
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: _logout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'chevron_right',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppTheme.lightTheme.colorScheme.surface,
      ),
    );
  }

  // Action methods
  void _toggleShift(String shiftType, bool isActive) {
    setState(() {
      if (shiftType == 'morning') {
        _isMorningShiftActive = isActive;
        if (isActive) _isEveningShiftActive = false;
      } else {
        _isEveningShiftActive = isActive;
        if (isActive) _isMorningShiftActive = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${shiftType.toUpperCase()} shift ${isActive ? 'started' : 'ended'}',
        ),
        backgroundColor: isActive
            ? AppTheme.getSuccessColor(true)
            : AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  void _startTrip() {
    setState(() {
      _isOnTrip = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trip started successfully!'),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _toggleStudentStatus(int index) {
    setState(() {
      _students[index]['isPresent'] = !(_students[index]['isPresent'] ?? false);
    });
  }

  void _markStudentPresent(int index) {
    setState(() {
      _students[index]['isPresent'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_students[index]['name']} marked as present'),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _markStudentAbsent(int index) {
    setState(() {
      _students[index]['isPresent'] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_students[index]['name']} marked as absent'),
        backgroundColor: AppTheme.getWarningColor(true),
      ),
    );
  }

  void _contactParent(Map<String, dynamic> student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${student['name']}\'s parent...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _viewStudentNotes(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Special Notes - ${student['name']}'),
        content: Text(
          (student['specialNotes'] as String?)?.isNotEmpty == true
              ? student['specialNotes']
              : 'No special notes for this student.',
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

  void _showEmergencyContacts() {
    showDialog(
      context: context,
      builder: (context) => EmergencyContactDialog(
        emergencyContacts: _emergencyContacts,
      ),
    );
  }

  void _openNavigation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening navigation app...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening settings...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have 3 new notifications'),
        backgroundColor: AppTheme.getWarningColor(true),
      ),
    );
  }

  void _viewRouteDetails(Map<String, dynamic> route) {
    Navigator.pushNamed(context, '/route-management');
  }

  void _navigateRoute(Map<String, dynamic> route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting navigation for ${route['name']}'),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _viewTripHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening trip history...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening help center...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // ✅ Remove token and user_type from SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('device_token');
              await prefs.remove('user_id');
              await prefs.remove('user_role');
              await prefs.remove('vehicle_id');

              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacementNamed(context, '/login'); // Go to login
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data refreshed successfully'),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }
}

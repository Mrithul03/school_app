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
import '../../core/services/background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'TripMapScreen.dart';

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
  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> studentlist = [];

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
  }

  void _startTracking(String shiftType) async {
    print("🔄 Request to start tracking with status: $shiftType");

    final service = FlutterBackgroundService();

    bool isRunning = await service.isRunning();
    print("ℹ️ Background service running: $isRunning");

    if (!isRunning) {
      print("🟢 Starting background service...");
      await service.startService();
    } else {
      print("⚠️ Background service already running");
    }

    print(
        "📡 Invoking 'start-tracking' with vehicleId: ${widget.vehicleId} and status: $shiftType");
    service.invoke('start-tracking', {
      "vehicle_id": widget.vehicleId,
      "status": 'start',
    });

    setState(() {
      _isTracking = true;
    });
    print("✅ _isTracking set to true");
  }

  void _stopTracking(String shiftType) {
    print("🛑 Request to stop tracking with status: $shiftType");

    final service = FlutterBackgroundService();

    print(
        "📡 Invoking 'stop-tracking' with vehicleId: ${widget.vehicleId} and status: $shiftType");
    service.invoke('stop-tracking', {
      "vehicle_id": widget.vehicleId,
      "status": 'stop',
    });

    setState(() {
      _isTracking = false;
    });
    print("✅ _isTracking set to false");
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token');

    if (token != null && token.isNotEmpty) {
      final api = ApiService();
      final data = await api.fetchCurrentUser(token);
      print('LoadUserData: $data');
      final vehicleId = data?['vehicle']?['id'];
      if (vehicleId == null) {
        print('❌ No vehicle ID found.');
        return;
      }

      final fetchedRoutes = await api.fetchStudentRoutes(token, vehicleId);
      print('routes: $fetchedRoutes');

      final fetchedStudentList = await api.fetchStudentList(token, vehicleId);
      print('studentlist: $fetchedStudentList');

      if (data != null && fetchedRoutes != null && fetchedRoutes.isNotEmpty && fetchedStudentList != null) {
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

          // Since fetchedRoutes is a list, assign directly
          _routes = fetchedRoutes
              .map((route) => {
                    'student_name': route['student']?['name'],
                    'student_phone': route['student']?['phone'],
                    'hom_lat': route['student']?['home_lat'],
                    'hom_lng': route['student']?['home_lng'],
                    'school': route['school']?['name'],
                    'route_order': route['route_order'],
                    'shift': route['shift'],
                    'trip_number': route['trip_number']
                  })
              .toList();

            studentlist = fetchedStudentList
              .map((student) => {
                    'student_name': student['name'],
                    'student_phone': student['phone'],
                    'hom_lat': student['home_lat'],
                    'hom_lng': student['home_lng'],
                    'school': student['school']?['name'],
                  })
              .toList();

          print('studentdatata: $_students');
          print('currentTripData: $childrenData');
          print('studentroute: $_routes');
          print('studentdatata: $studentlist');
        });
      }
    }
  }

  // Mock emergency contacts
  final List<Map<String, dynamic>> _emergencyContacts = [
    // {
    //   "name": "Springfield Elementary School",
    //   "type": "School",
    //   "phone": "+1 (555) 100-2000"
    // },
    {"name": "Emergency Services", "type": "Police", "phone": "911"},
    // {
    //   "name": "School Transportation Office",
    //   "type": "School",
    //   "phone": "+1 (555) 100-2001"
    // },
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
        // actions: [
        //   IconButton(
        //     onPressed: () => _showNotifications(),
        //     icon: Stack(
        //       children: [
        //         CustomIconWidget(
        //           iconName: 'notifications',
        //           color: Colors.white,
        //           size: 6.w,
        //         ),
        //         Positioned(
        //           right: 0,
        //           top: 0,
        //           child: Container(
        //             width: 2.5.w,
        //             height: 2.5.w,
        //             decoration: BoxDecoration(
        //               color: AppTheme.getWarningColor(true),
        //               shape: BoxShape.circle,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        //   SizedBox(width: 2.w),
        // ],
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
              // onNavigationTap: _openNavigation,
              onEmergencyTap: _showEmergencyContacts,
              // onRefreshTap: _refreshData,
              // onSettingsTap: _openSettings,
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
        // Header with counts
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
                      'Total Students: ${studentlist.length}',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    // Text(
                    //   // If you don't have isPresent in studentlist, this will just show zero
                    //   'Present: ${studentlist.where((s) => s['isPresent'] == true).length} | Absent: ${studentlist.where((s) => s['isPresent'] == false).length}',
                    //   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    //     color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    //   ),
                    // ),
                  ],
                ),
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              //   decoration: BoxDecoration(
              //     color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Text(
              //     'Swipe right to mark present',
              //     style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              //       color: AppTheme.lightTheme.colorScheme.primary,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),

        // List of students
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            itemCount: studentlist.length,
            itemBuilder: (context, index) {
              final student = studentlist[index];
              return StudentCard(
                student: {
                  'student_name': student['student_name'],
                  'student_phone': student['student_phone'],
                  // 'isPresent': student['isPresent'] ?? false, // If not available, defaults to false
                },
                // onToggleStatus: () => _toggleStudentStatus(index),
                // onMarkPresent: () => _markStudentPresent(index),
                // onMarkAbsent: () => _markStudentAbsent(index),
                // onContactParent: () => _contactParent(student),
                // onViewNotes: () => _viewStudentNotes(student),
                // onEmergencyContact: () => _showEmergencyContacts(),
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

    Widget buildTripSection(String shift) {
      final trips = groupedRoutes[shift]!;
      if (trips.isEmpty) return SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${shift[0].toUpperCase()}${shift.substring(1)} Trips',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          for (var tripEntry in trips.entries) ...[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripMapScreen(
                      tripRoutes: tripEntry.value,
                      tripNumber: tripEntry.key,
                      shift: shift,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Trip ${tripEntry.key}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            for (var route in tripEntry.value) ...[
              Container(
                margin: EdgeInsets.only(bottom: 3.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route['student_name'] ?? 'Unknown Student',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Order: ${route['route_order'] ?? 'N/A'}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          buildTripSection('morning'),
          SizedBox(height: 3.h),
          buildTripSection('evening'),
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
                    child: Container(
                      width: 25.w,
                      height: 25.w,
                      color: Colors.grey.shade200, // background color
                      child: Icon(
                        Icons.person,
                        size: 15.w,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Column(
                  children: (_students ?? []).map((student) {
                    return Column(
                      children: [
                        Text(
                          student['driver'] ?? 'Unknown',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          student['vehicle_number'] ?? 'Unknown',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 1.h),
                      ],
                    );
                  }).toList(),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                //   decoration: BoxDecoration(
                //     color:
                //         AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     'License: CDL-A • Exp: 12/2025',
                //     style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                //       color: AppTheme.getSuccessColor(true),
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // _buildProfileOption(
          //   icon: 'settings',
          //   title: 'Settings',
          //   subtitle: 'App preferences and notifications',
          //   onTap: _openSettings,
          // ),
          // _buildProfileOption(
          //   icon: 'history',
          //   title: 'Trip History',
          //   subtitle: 'View past trips and reports',
          //   onTap: _viewTripHistory,
          // ),
          // _buildProfileOption(
          //   icon: 'help',
          //   title: 'Help & Support',
          //   subtitle: 'Get help and contact support',
          //   onTap: _showHelp,
          // ),
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

  // void _toggleStudentStatus(int index) {
  //   setState(() {
  //     _students[index]['isPresent'] = !(_students[index]['isPresent'] ?? false);
  //   });
  // }

  // void _markStudentPresent(int index) {
  //   setState(() {
  //     _students[index]['isPresent'] = true;
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('${_students[index]['name']} marked as present'),
  //       backgroundColor: AppTheme.getSuccessColor(true),
  //     ),
  //   );
  // }

  // void _markStudentAbsent(int index) {
  //   setState(() {
  //     _students[index]['isPresent'] = false;
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('${_students[index]['name']} marked as absent'),
  //       backgroundColor: AppTheme.getWarningColor(true),
  //     ),
  //   );
  // }

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

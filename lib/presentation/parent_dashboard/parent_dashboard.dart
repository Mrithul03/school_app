import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/child_status_card.dart';
import './widgets/current_trip_status_card.dart';
import './widgets/notification_card.dart';
import './widgets/quick_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/api.dart';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ParentDashboard extends StatefulWidget {
  final int vehicleId;
  const ParentDashboard({Key? key, required this.vehicleId}) : super(key: key);

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  Map<String, dynamic>? currentTripData;
  List<Map<String, dynamic>> childrenData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUser();
    _handleRefresh();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token');

    if (token != null && token.isNotEmpty) {
      final api = ApiService();
      final data = await api.fetchCurrentUser(token);
      print('LoadUserData:$data');
      final locationsdata = await api.fetchCurrentvehicle_location(token);
      print('locationsdata:$locationsdata');

      if (data != null && locationsdata != null) {
        setState(() {
          currentTripData = {
            'status': locationsdata['status'],
            'driver': data['vehicle']?['driver'],
            'vehicle_number': data['vehicle']?['vehicle_number'],
            'student_id':data['student']?['id'],
            'student_name': data['student']?['name'],
            'parent': data['student']?['parent'],
            'school': data['school']?['name'],
          };
          childrenData = [
            {
              'status': 'Running', // or from API if available
              'driver': data['vehicle']?['driver'],
              'vehicle_number': data['vehicle']?['vehicle_number'],
              'student_name': data['student']?['name'],
            }
          ];

          print('currentTripData:$currentTripData');
          print('currentTripData:$childrenData');
        });
      }
    }
  }

  // updateLocation.dart
Future<void> updateLocation(BuildContext context, int studentId, String token) async {
  try {
    if (studentId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No student ID found")),
      );
      return;
    }

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No token found")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final api = ApiService();
    await api.updateLocation(
      studentId,
      token,
      position.latitude,
      position.longitude,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Location updated successfully")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("⚠️ Error: $e")),
    );
  }
}





  // Mock data for notifications
  final List<Map<String, dynamic>> notificationsData = [
    {
      "id": 1,
      "title": "Route Change Alert",
      "message":
          "Morning pickup time changed to 8:10 AM due to traffic conditions",
      "time": "5 minutes ago",
      "type": "alert",
      "isRead": false,
    },
    {
      "id": 2,
      "title": "Driver Update",
      "message": "Michael Johnson is your assigned driver for this week",
      "time": "1 hour ago",
      "type": "info",
      "isRead": true,
    },
    {
      "id": 3,
      "title": "Payment Reminder",
      "message": "Monthly transportation fee is due in 3 days",
      "time": "2 hours ago",
      "type": "delay",
      "isRead": false,
    },
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trip data updated'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'SchoolTrip Manager',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            isDarkMode ? AppTheme.surfaceDark : AppTheme.primaryLight,
        foregroundColor:
            isDarkMode ? AppTheme.textPrimaryDark : AppTheme.onPrimaryLight,
        actions: [
          IconButton(
            onPressed: () {
              // Handle notifications
            },
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: isDarkMode
                      ? AppTheme.textPrimaryDark
                      : AppTheme.onPrimaryLight,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'home',
                color: isDarkMode
                    ? AppTheme.primaryDark
                    : Color.fromARGB(255, 255, 255, 255),
                size: 24,
              ),
              text: 'Home',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'directions_bus',
                color: isDarkMode
                    ? const Color.fromARGB(255, 245, 240, 240)
                    : const Color.fromARGB(255, 255, 255, 255),
                size: 24,
              ),
              text: 'Trips',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'message',
                color: isDarkMode
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 255, 255, 255),
                size: 24,
              ),
              text: 'Messages',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                color: isDarkMode
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 255, 255, 255),
                size: 24,
              ),
              text: 'Profile',
            ),
          ],
          labelColor: Colors.white, // 👈 selected tab text color
          unselectedLabelColor: Colors.white70, // 👈 unselected tab text color
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildTripsTab(),
          _buildMessagesTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12.w,
                          height: 0.5.h,
                          margin: EdgeInsets.symmetric(vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        ListTile(
                          leading: CustomIconWidget(
                            iconName: 'phone',
                            color: Theme.of(context).colorScheme.error,
                            size: 24,
                          ),
                          title: Text('Call School Office'),
                          subtitle: Text('+1 (555) 123-4567'),
                          onTap: () => Navigator.pop(context),
                        ),
                        ListTile(
                          leading: CustomIconWidget(
                            iconName: 'directions_bus',
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          title: Text('Contact Driver'),
                          subtitle: Text('Michael Johnson'),
                          onTap: () => Navigator.pop(context),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                );
              },
              icon: CustomIconWidget(
                iconName: 'emergency',
                color: Colors.white,
                size: 20,
              ),
              label: Text('Emergency'),
              backgroundColor: Theme.of(context).colorScheme.error,
            )
          : null,
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // Children Section
            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: childrenData.length,
            //   itemBuilder: (context, index) {
            //     final child = childrenData[index];
            //     return ChildStatusCard(
            //       childData: child,
            //       onTap: () {
            //         Navigator.pushNamed(context, '/live-trip-tracking');
            //       },
            //       onContactDriver: () {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //             content: Text('Calling driver...'),
            //             behavior: SnackBarBehavior.floating,
            //           ),
            //         );
            //       },
            //     );
            //   },
            // ),

            // SizedBox(height: 2.h),

            // Current Trip Status
            if (currentTripData != null)
              CurrentTripStatusCard(
                tripData: currentTripData!,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/live-trip-tracking',
                    arguments: {'vehicleId': widget.vehicleId},
                  );
                },
              ),

            SizedBox(height: 2.h),

            // Recent Notifications
            if (notificationsData.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Recent Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              SizedBox(height: 1.h),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: notificationsData.take(3).length,
                itemBuilder: (context, index) {
                  final notification = notificationsData[index];
                  return NotificationCard(
                    notificationData: notification,
                    onDismiss: () {
                      setState(() {
                        notificationsData.removeAt(index);
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 2.h),
            ],

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: 1.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Expanded(
                    child: QuickActionButton(
                      title: 'Payment Status',
                      subtitle: 'Check monthly fees',
                      iconName: 'payment',
                      onTap: () {
                        Navigator.pushNamed(context, '/payment-status');
                      },
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: QuickActionButton(
                      title: 'Trip Calendar',
                      subtitle: 'View schedule',
                      iconName: 'calendar_today',
                      onTap: () {
                        // Handle trip calendar
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'All Trips',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(height: 1.h),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: childrenData.length,
            itemBuilder: (context, index) {
              final child = childrenData[index];
              return ChildStatusCard(
                childData: child,
                onTap: () {
                  Navigator.pushNamed(context, '/live-trip-tracking');
                },
                onContactDriver: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling driver...')),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Messages & Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(height: 1.h),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: notificationsData.length,
            itemBuilder: (context, index) {
              final notification = notificationsData[index];
              return NotificationCard(
                notificationData: notification,
                onDismiss: () {
                  setState(() {
                    notificationsData.removeAt(index);
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),

          // Profile Header
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      isDarkMode ? AppTheme.shadowDark : AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDarkMode
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight)
                        .withValues(alpha: 0.1),
                  ),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: isDarkMode
                        ? AppTheme.primaryDark
                        : AppTheme.primaryLight,
                    size: 10.w,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Maria Rodriguez',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'maria.rodriguez@email.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Profile Options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                QuickActionButton(
                  title: 'Account Settings',
                  subtitle: 'Manage your account',
                  iconName: 'settings',
                  onTap: () {},
                ),
                SizedBox(height: 2.h),
                QuickActionButton(
                  title: 'Children Management',
                  subtitle: 'Add or edit children',
                  iconName: 'family_restroom',
                  onTap: () {},
                ),
                SizedBox(height: 2.h),

                // 📌 New Button to Update Location
                QuickActionButton(
                  title: 'Update Home Location',
                  subtitle: 'Set current location as home',
                  iconName: 'location_on',
                  iconColor: Colors.green,
                  onTap: () async {
                    // Show confirmation dialog
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Location Update"),
                        content: Text(
                            "Do you want to update your home location to your current GPS position?"),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          ElevatedButton(
                            child: Text("Yes, Update"),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // You can fetch studentId & token from SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      int studentId = prefs.getInt("student_id") ?? 1;
                      String token = prefs.getString("device_token") ?? "";

                      await updateLocation(context, studentId, token);
                    }
                  },
                ),
                SizedBox(height: 2.h),

                QuickActionButton(
                  title: 'Notification Settings',
                  subtitle: 'Customize alerts',
                  iconName: 'notifications_active',
                  onTap: () {},
                ),
                SizedBox(height: 2.h),
                QuickActionButton(
                  title: 'Help & Support',
                  subtitle: 'Get assistance',
                  iconName: 'help',
                  onTap: () {},
                ),
                SizedBox(height: 2.h),
                QuickActionButton(
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  iconName: 'logout',
                  iconColor: Theme.of(context).colorScheme.error,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('device_token');
                    await prefs.remove('user_id');
                    await prefs.remove('user_role');
                    await prefs.remove('vehicle_id');

                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

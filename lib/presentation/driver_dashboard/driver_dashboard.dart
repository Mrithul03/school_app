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
import 'package:permission_handler/permission_handler.dart';

import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; // for Platform
import 'package:device_info_plus/device_info_plus.dart'; // for DeviceInfoPlugin
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDashboard extends StatefulWidget {
  final int vehicleId;
  const DriverDashboard({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  bool _isMorningShiftActive = false;
  bool _isEveningShiftActive = false;
  bool _isOnTrip = false;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> childrenData = [];
  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> studentlist = [];
  List<Map<String, dynamic>> paymentList = [];

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

  void _startTracking() async {
    print("🔄 Request to start tracking ");

    final service = FlutterBackgroundService();

    bool isRunning = await service.isRunning();
    print("ℹ️ Background service running: $isRunning");

    if (!isRunning) {
      print("🟢 Starting background service...");
      await service.startService();
    } else {
      print("⚠️ Background service already running");
    }

    print("📡 Invoking 'start-tracking' with vehicleId: ${widget.vehicleId}");
    service.invoke('start-tracking', {
      "vehicle_id": widget.vehicleId,
      "status": 'start',
    });

    setState(() {
      _isTracking = true;
    });

    // ✅ Show toast after successfully starting tracking
    Fluttertoast.showToast(
      msg: "🚗 Driver started sending location",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    print("✅ _isTracking set to true");
  }

  void _stopTracking() {
    print("🛑 Request to stop tracking ");

    final service = FlutterBackgroundService();

    print("📡 Invoking 'stop-tracking' with vehicleId: ${widget.vehicleId}");
    service.invoke('stop-tracking', {
      "vehicle_id": widget.vehicleId,
      "status": 'stop',
    });

    setState(() {
      _isTracking = false;
    });
    print("✅ _isTracking set to false");
  }

  Future<bool> _requestPermissions() async {
    // 1️⃣ Foreground location
    var foregroundStatus = await Permission.locationWhenInUse.request();
    if (!foregroundStatus.isGranted) {
      print("❌ Foreground location permission denied");
      return false;
    }

    // 2️⃣ Background location (only if foreground granted)
    // Note: On Android 10+, you must ask separately for "always" location.
    var backgroundStatus = await Permission.locationAlways.request();
    if (!backgroundStatus.isGranted) {
      print("❌ Background location permission denied");
      return false;
    }

    // 3️⃣ Notification permission (needed for foreground service)
    var notificationStatus = await Permission.notification.request();
    if (!notificationStatus.isGranted) {
      print("❌ Notification permission denied");
      return false;
    }

    // 4️⃣ Battery optimization (ask if restricted)
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      print("⚠️ Battery optimization not ignored. Requesting...");
      var batteryStatus = await Permission.ignoreBatteryOptimizations.request();
      if (!batteryStatus.isGranted) {
        print("❌ Battery optimization not granted");
        return false; // User must allow manually
      }
    }

    print("✅ All permissions granted including battery optimization");
    return true;
  }

  Future<void> _loadUser() async {
    setState(() => isLoading = true);
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

      final payments = await api.getPayments(token);
        print('loadpaymentdata: $payments');

      if (data != null &&
          fetchedRoutes != null &&
          fetchedRoutes.isNotEmpty &&
          fetchedStudentList != null) {
        setState(() {
          _students = [
            {
              'id': data['id'],
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
                    'id': route['id'],
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
                    'id': student['id'],
                    'student_name': student['name'],
                    'student_phone': student['phone'],
                    'hom_lat': student['home_lat'],
                    'hom_lng': student['home_lng'],
                    'school': student['school']?['name'],
                  })
              .toList();

          setState(() {
              paymentList = List<Map<String, dynamic>>.from(payments);
            });

          print('studentdatata: $_students');
          print('currentTripData: $childrenData');
          print('studentroute: $_routes');
          print('studentdata: $studentlist');
        });
        setState(() => isLoading = false);
      }
    }
  }

  // Future<void> requestBatteryOptimizationPermission() async {
  //   if (await Permission.ignoreBatteryOptimizations.isDenied) {
  //     await openAppSettings();
  //   }
  // }

  // Future<void> checkOEMSettings() async {
  //   if (Platform.isAndroid) {
  //     final deviceInfo = DeviceInfoPlugin();
  //     final androidInfo = await deviceInfo.androidInfo;
  //     final brand = androidInfo.brand.toLowerCase();

  //     if (['xiaomi', 'oppo', 'vivo', 'huawei', 'realme'].contains(brand)) {
  //       // 👉 Show a dialog/snackbar to guide the user
  //       // e.g., "Please enable AutoStart and Background Activity in settings"
  //       print("⚠️ OEM brand detected: $brand. Ask user to enable AutoStart.");
  //     }
  //   }
  // }

  Future<void> _openSettings() async {
    final opened =
        await openAppSettings(); // This opens the app's settings page
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open app settings.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
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


  void _openPaymentForm(BuildContext context, Map<String, dynamic> student) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  int selectedYear = DateTime.now().year;
  String selectedStatus = "Paid";

  // ✅ Get unpaid months for this student/year
  final unpaidMonths = List.generate(12, (index) => index + 1).where((monthValue) {
    return !paymentList.any((p) =>
      p['student_id'] == student['id'] &&
      p['month'] == monthValue &&
      p['year'] == selectedYear &&
      p['is_paid'] == true
    );
  }).toList();

  // ✅ If all months are paid
  if (unpaidMonths.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ All months already paid for this year")),
    );
    return;
  }

  int selectedMonth = unpaidMonths.first;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Mark Payment - ${student['student_name']}"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Month & Year dropdown
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedMonth,
                        decoration: const InputDecoration(labelText: "Month"),
                        items: unpaidMonths.map((monthValue) {
                          final monthName = [
                            "Jan","Feb","Mar","Apr","May","Jun",
                            "Jul","Aug","Sep","Oct","Nov","Dec"
                          ][monthValue - 1];
                          return DropdownMenuItem(
                            value: monthValue,
                            child: Text(monthName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) selectedMonth = val;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedYear,
                        decoration: const InputDecoration(labelText: "Year"),
                        items: List.generate(5, (index) {
                          final year = DateTime.now().year - 2 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) selectedYear = val;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Amount"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter amount";
                    if (double.tryParse(value) == null) return "Enter valid number";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Paid / Unpaid dropdown
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: "Status"),
                  items: ["Paid", "Unpaid"].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      selectedStatus = val;
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Paid Date (only if Paid)
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  enabled: selectedStatus == "Paid",
                  decoration: const InputDecoration(
                    labelText: "Paid Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: selectedStatus == "Paid"
                      ? () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(picked);
                          }
                        }
                      : null,
                  validator: (value) {
                    if (selectedStatus == "Paid" &&
                        (value == null || value.isEmpty)) {
                      return "Select paid date";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Submit"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString("device_token") ?? "";

              if (_formKey.currentState!.validate()) {
                final success = await ApiService().createPayment(
                  studentId: student['id'],
                  month: selectedMonth,
                  year: selectedYear,
                  amount: double.tryParse(amountController.text) ?? 0,
                  isPaid: selectedStatus == "Paid",
                  paidOn: selectedStatus == "Paid" &&
                          dateController.text.isNotEmpty
                      ? dateController.text
                      : null,
                  token: token,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Payment saved")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ApiService.lastError ?? "❌ Failed to save payment")),
                  );
                }
              }
            },
          ),
        ],
      );
    },
  );
}


  void _showEditDialog(BuildContext context, Map<String, dynamic> route) {
    final TextEditingController orderController =
        TextEditingController(text: route['route_order']?.toString() ?? "");
    final TextEditingController tripNumberController =
        TextEditingController(text: route['trip_number']?.toString() ?? "");

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Route"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Route Order (editable)
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Route Order",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Trip Number (editable)
              TextField(
                controller: tripNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Trip Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                // Validate route order
                final newOrder = int.tryParse(orderController.text);
                if (newOrder == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("⚠️ Please enter a valid route order")),
                  );
                  return;
                }

                // Validate trip number
                final newTripNumber = int.tryParse(tripNumberController.text);
                if (newTripNumber == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("⚠️ Please enter a valid trip number")),
                  );
                  return;
                }

                // Validate route id
                final routeId = int.tryParse(route['id']?.toString() ?? "");
                if (routeId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Invalid Route ID")),
                  );
                  return;
                }

                Navigator.pop(ctx); // close popup

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('device_token') ?? "";

                final api = ApiService();
                final success = await api.editRouteOrder(
                  routeId,
                  token,
                  newOrder,
                  newTripNumber, // pass trip_number as named parameter
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("✅ Route updated successfully")),
                  );
                  _loadUser(); // reload routes
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Failed to update route")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // ⏳ Loading Spinner
            if (isLoading) ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: const CircularProgressIndicator(),
                ),
              ),
            ]
            // ✅ Data Loaded
            else ...[
              // 🚦 Start / Stop Trip Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.red : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!_isTracking) {
                      bool granted = await _requestPermissions();
                      if (granted) {
                        _startTracking();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Location & background permissions required to start trip",
                            ),
                          ),
                        );
                      }
                    } else {
                      // 🛑 Confirmation before stopping
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Stop Tracking"),
                          content: const Text(
                              "Are you sure you want to stop sending location?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Stop"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        _stopTracking();
                      }
                    }
                  },
                  child: Text(
                    _isTracking ? "Stop Trip" : "Start Trip",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ⚙️ Quick Actions
              QuickActionsBar(
                onEmergencyTap: _showEmergencyContacts,
                onSettingsTap: _openSettings,
              ),

              SizedBox(height: 10.h),
            ],
          ],
        ),
      ),
    );
  }

  // Widget _buildStudentsTab() {
  //   return RefreshIndicator(
  //     onRefresh: _refreshData,
  //     color: AppTheme.lightTheme.colorScheme.primary,
  //     child: Column(
  //       children: [
  //         // Header with counts
  //         Container(
  //           width: double.infinity,
  //           padding: EdgeInsets.all(4.w),
  //           color: AppTheme.lightTheme.colorScheme.surface,
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Total Students: ${studentlist.length}',
  //                       style:
  //                           AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                     SizedBox(height: 0.5.h),
  //                     // Text(
  //                     //   // If you don't have isPresent in studentlist, this will just show zero
  //                     //   'Present: ${studentlist.where((s) => s['isPresent'] == true).length} | Absent: ${studentlist.where((s) => s['isPresent'] == false).length}',
  //                     //   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
  //                     //     color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
  //                     //   ),
  //                     // ),
  //                   ],
  //                 ),
  //               ),
  //               // Container(
  //               //   padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
  //               //   decoration: BoxDecoration(
  //               //     color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
  //               //     borderRadius: BorderRadius.circular(20),
  //               //   ),
  //               //   child: Text(
  //               //     'Swipe right to mark present',
  //               //     style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
  //               //       color: AppTheme.lightTheme.colorScheme.primary,
  //               //       fontWeight: FontWeight.w500,
  //               //     ),
  //               //   ),
  //               // ),
  //             ],
  //           ),
  //         ),

  //         // List of students
  //         Expanded(
  //           child: ListView.builder(
  //             padding: EdgeInsets.symmetric(vertical: 2.h),
  //             itemCount: studentlist.length,
  //             itemBuilder: (context, index) {
  //               final student = studentlist[index];
  //               return StudentCard(
  //                 student: {
  //                   'student_name': student['student_name'],
  //                   'student_phone': student['student_phone'],
  //                   // 'isPresent': student['isPresent'] ?? false, // If not available, defaults to false
  //                 },
  //                 // onToggleStatus: () => _toggleStudentStatus(index),
  //                 // onMarkPresent: () => _markStudentPresent(index),
  //                 // onMarkAbsent: () => _markStudentAbsent(index),
  //                 // onContactParent: () => _contactParent(student),
  //                 // onViewNotes: () => _viewStudentNotes(student),
  //                 // onEmergencyContact: () => _showEmergencyContacts(),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStudentsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            color: AppTheme.lightTheme.colorScheme.surface,
            child: Row(
              children: [
                if (isLoading) ...[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                ]
                // ✅ Data Loaded
                else ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Students: ${studentlist.length}',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Present: ${studentlist.where((s) => s['isPresent'] == true).length} | '
                          'Absent: ${studentlist.where((s) => s['isPresent'] == false).length}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Student List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: studentlist.length,
              itemBuilder: (context, index) {
                final student = studentlist[index];

                // ✅ Safely extract ID
                final int? studentId = student['id'] is int
                    ? student['id']
                    : int.tryParse(student['id']?.toString() ?? "");

                final isPresent = student['isPresent'] ?? false;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(3.w),
                    title: Text(
                      student['student_name'] ?? "Unknown",
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (student['student_phone'] != null)
                          GestureDetector(
                            onTap: () async {
                              final Uri callUri = Uri(
                                  scheme: 'tel',
                                  path: student['student_phone']);
                              if (await canLaunchUrl(callUri)) {
                                await launchUrl(callUri);
                              } else {
                                print("❌ Could not launch dialer");
                              }
                            },
                            child: Text(
                              "📞 ${student['student_phone']}",
                              style: TextStyle(
                                color: Colors.blue, // makes it look tappable
                              ),
                            ),
                          ),
                        if (student.containsKey('last_payment'))
                          Text(
                            "💰 Last Payment: ${student['last_payment']}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 💳 Payment button
                        IconButton(
                          icon: const Icon(Icons.payment,
                              color: Colors.blueAccent),
                          onPressed: () {
                            if (studentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("❌ Missing student ID")),
                              );
                              return;
                            }

                            // ✅ Always pass ID with other details
                            _openPaymentForm(context, {
                              "id": studentId,
                              "student_name": student['student_name'] ?? "",
                              "student_phone": student['student_phone'] ?? "",
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
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
          if (isLoading) ...[
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: const CircularProgressIndicator(),
              ),
            ),
          ]
          // ✅ Data Loaded
          else ...[
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
                      // ✏️ Edit Button
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: AppTheme.lightTheme.colorScheme.primary),
                        onPressed: () {
                          _showEditDialog(context, {
                            ...route,
                            'id': route['id'], // 👈 normalize route_id → id
                            'shift': route['shift'], // 👈 from loop
                            'trip_number':
                                route['trip_number'], // 👈 from trip section
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
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

  void _openAppSettings(BuildContext context) async {
    final opened = await openAppSettings();
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open settings.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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

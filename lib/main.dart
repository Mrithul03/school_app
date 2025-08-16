import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'core/app_export.dart';
import 'widgets/custom_error_widget.dart';
import 'presentation/driver_dashboard/driver_dashboard.dart';
import 'presentation/parent_dashboard/parent_dashboard.dart';
import 'presentation/login_screen/login_screen.dart';
import '../presentation/live_trip_tracking/live_trip_tracking.dart';

import 'package:firebase_core/firebase_core.dart';
import '../../core/services/driver_location_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../core/services/background_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  

// 🚨 Custom error handler
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(errorDetails: details);
  };

  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false, // set true if you want auto-restart
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
    ),
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token');
    final role = prefs.getString('user_role');
    final vehicleId = prefs.getInt('vehicle_id');
    print('🔐 Token: $token');
    print('👤 Role: $role');
    print('🚌 Vehicle ID: $vehicleId');

    if (token != null && token.isNotEmpty) {
      if (role == 'driver' && vehicleId != null) {
        print('➡️ Navigating to DriverDashboard');
        return DriverDashboard(vehicleId: vehicleId);
      } else if (role == 'parent' && vehicleId != null) {
        print('➡️ Navigating to ParentDashboard');
        return ParentDashboard(vehicleId: vehicleId);
      }
    }

    print('🛑 Navigating to LoginScreen');

    return const LoginScreen(); // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'School Trip Manager',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,

          // ✅ Dynamically choose home screen
          home: FutureBuilder<Widget>(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                return snapshot.data!;
              }
            },
          ),

          // ✅ Use onGenerateRoute instead of routes
          onGenerateRoute: (settings) {
            if (settings.name == '/login') {
              return MaterialPageRoute(
                  builder: (context) => const LoginScreen());
            } else if (settings.name == '/driver-dashboard') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) =>
                    DriverDashboard(vehicleId: args['vehicle_id']),
              );
            } else if (settings.name == '/parent-dashboard') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) =>
                    ParentDashboard(vehicleId: args['vehicle_id']),
              );
            } else if (settings.name == '/live-trip-tracking') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => LiveTripTrackingScreen(
                    vehicleId: args['vehicleId']), // ✅ Match the push
              );
            }

            return null;
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/driver_dashboard/driver_dashboard.dart';
import '../presentation/parent_dashboard/parent_dashboard.dart';

import '../presentation/live_trip_tracking/live_trip_tracking.dart';
import '../presentation/route_management/route_management.dart';
import '../presentation/payment_status/payment_status.dart';


class AppRoutes {
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String driverDashboard = '/driver-dashboard';
  static const String parentDashboard = '/parent-dashboard';

  static const String liveTripTracking = '/live-trip-tracking';
  static const String routeManagement = '/route-management';
  static const String paymentStatus = '/payment-status';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => LoginScreen(),
    loginScreen: (context) => LoginScreen(),

    parentDashboard: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      final vehicleId = args['vehicle_id'] as int? ?? 0;
      return ParentDashboard(vehicleId: vehicleId);
    },

    driverDashboard: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      final vehicleId = args['vehicle_id'] as int? ?? 0;
      return DriverDashboard(vehicleId: vehicleId);
    },

    liveTripTracking: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      final vehicleId = args['vehicle_id'] as int? ?? 0;
      return LiveTripTrackingScreen(vehicleId: vehicleId);
    },
    routeManagement: (context) => RouteManagement(),
    paymentStatus: (context) => PaymentStatus(),
  };
}

  

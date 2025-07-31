import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/driver_dashboard/driver_dashboard.dart';


class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String driverDashboard = '/driver-dashboard';


  static Map<String, WidgetBuilder> routes = {
    initial: (context) => LoginScreen(),
    driverDashboard: (context) => DriverDashboard(),
   
    // TODO: Add your other routes here
  };
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:app/api.dart';
import '../../core/app_export.dart';
import './widgets/login_form_widget.dart';
import './widgets/app_logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _schoolCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'parent';

  void _handleLogin(String phone, String password, String schoolCode, String role) async {
  setState(() {
    _isLoading = true;
  });

  final api = ApiService();

  try {
    final token = await api.login(
      schoolCode: schoolCode,
      phone: phone,
      password: password,
      role: role,
    );

    if (token.isNotEmpty) {
      print("Login success: $token");

      // TODO: Save token to SharedPreferences

      // Navigate to the next screen
      Navigator.pushReplacementNamed(context,  '/driver-dashboard');
    }
  } catch (e) {
    print("Login failed: $e");
    // TODO: Show a snackbar or alert with the error message
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // App Logo
                const AppLogoWidget(),
                SizedBox(height: 6.h),

                // Welcome Text
                Text(
                  'Welcome Back',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Sign in to access your school transportation dashboard',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),

                // Login Form
                LoginFormWidget(
                  isLoading: _isLoading,
                  onLogin: _handleLogin,
                ),

                SizedBox(height: 6.h),

                // Safety Message
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.getSuccessColor(true).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getSuccessColor(true).withAlpha(60),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'security',
                        color: AppTheme.getSuccessColor(true),
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Your child\'s safety is our priority. All data is encrypted and secure.',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.getSuccessColor(true),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:app/api.dart';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:app/api.dart';
import '../../core/app_export.dart';
import './widgets/login_form_widget.dart';
import './widgets/app_logo_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/api.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final parentController = TextEditingController();
  final studentController = TextEditingController();

  bool isLoading = false;

  bool _obscurePassword = true;


  void handleRegister() async {
    setState(() => isLoading = true);

    final result = await ApiService.parentRegister(
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      parentName: parentController.text.trim(),
      studentName: studentController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result["success"] == true) {
      // ✅ Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please login.")),
      );
      Navigator.pop(context); // back to login screen
    } else {
      // ❌ Error (API returns {"error": "..."} as string)
      String errorMsg = "Something went wrong";
      if (result["error"] != null) {
        errorMsg = result["error"].toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
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
                  'Create Account',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Register to access your school transportation dashboard',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),

                // Register Form
                Column(
                  children: [
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: parentController,
                      decoration: const InputDecoration(
                        labelText: "Parent Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: studentController,
                      decoration: const InputDecoration(
                        labelText: "Student Name",
                        prefixIcon: Icon(Icons.school),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 4.h),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: handleRegister,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Register"),
                          ),
                  ],
                ),
                SizedBox(height: 6.h),

                // Already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

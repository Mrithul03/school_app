import 'package:flutter/material.dart';

import '../core/app_export.dart'; // Make sure AppRoutes & AppTheme are set

class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final String? errorMessage;

  const CustomErrorWidget({
    Key? key,
    this.errorDetails,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "Something went wrong",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ??
                      'An unexpected error occurred. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    bool canPop = Navigator.canPop(context);
                    if (canPop) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.pushNamed(context, AppRoutes.initial);
                    }
                  },
                  child: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

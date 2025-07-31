import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 20.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomIconWidget(
              iconName: 'directions_bus',
              color: Colors.white,
              size: 48,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'SchoolTrip Manager',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Safe • Reliable • Connected',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

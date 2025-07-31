import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ShiftStatusCard extends StatelessWidget {
  final String shiftType;
  final bool isActive;
  final VoidCallback? onStartTrip;
  final VoidCallback? onEndTrip;

  const ShiftStatusCard({
    Key? key,
    required this.shiftType,
    required this.isActive,
    this.onStartTrip,
    this.onEndTrip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: shiftType == 'Morning' ? 'wb_sunny' : 'nights_stay',
                  color: isActive
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$shiftType Shift',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      isActive ? 'Active Now' : 'Inactive',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: isActive
                            ? AppTheme.getSuccessColor(true)
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.getSuccessColor(true).withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.getSuccessColor(true)
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      isActive ? 'ON' : 'OFF',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppTheme.getSuccessColor(true)
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isActive ? null : onStartTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive
                        ? AppTheme.lightTheme.colorScheme.outline
                        : AppTheme.getSuccessColor(true),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isActive ? 0 : 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'play_arrow',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Start Trip',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: !isActive ? null : onEndTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isActive
                        ? AppTheme.lightTheme.colorScheme.outline
                        : AppTheme.lightTheme.colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: !isActive ? 0 : 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'stop',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'End Trip',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

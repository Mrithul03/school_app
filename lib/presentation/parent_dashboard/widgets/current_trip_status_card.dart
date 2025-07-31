import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrentTripStatusCard extends StatelessWidget {
  final Map<String, dynamic> tripData;
  final VoidCallback? onTap;

  const CurrentTripStatusCard({
    Key? key,
    required this.tripData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String status = tripData['status'] as String? ?? 'Unknown';
    final String driverName =
        tripData['driverName'] as String? ?? 'Unknown Driver';
    final String vehicleNumber = tripData['vehicleNumber'] as String? ?? 'N/A';
    final String estimatedTime =
        tripData['estimatedTime'] as String? ?? '--:--';
    final String tripType = tripData['tripType'] as String? ?? 'Morning';

    Color _getStatusColor() {
      switch (status.toLowerCase()) {
        case 'on route':
          return AppTheme.getSuccessColor(!isDarkMode);
        case 'delayed':
          return AppTheme.getWarningColor(!isDarkMode);
        case 'arrived':
          return isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight;
        default:
          return isDarkMode
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight;
      }
    }

    IconData _getStatusIcon() {
      switch (status.toLowerCase()) {
        case 'on route':
          return Icons.directions_bus;
        case 'delayed':
          return Icons.schedule;
        case 'arrived':
          return Icons.location_on;
        default:
          return Icons.info_outline;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? AppTheme.shadowDark : AppTheme.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$tripType Trip',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _getStatusIcon().codePoint.toString(),
                        color: _getStatusColor(),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        status,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        driverName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        vehicleNumber,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color:
                    (isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Estimated Arrival',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    estimatedTime,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

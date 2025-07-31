import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmergencyContactButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const EmergencyContactButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: ElevatedButton(
        onPressed: onPressed ?? () => _showEmergencyOptions(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          elevation: 4,
          shadowColor:
              Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'emergency',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Emergency Contact',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Emergency Contacts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'phone',
                  color: Theme.of(context).colorScheme.error,
                  size: 24,
                ),
              ),
              title: Text('Call School Office'),
              subtitle: Text('+1 (555) 123-4567'),
              onTap: () {
                Navigator.pop(context);
                // Handle call school office
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'directions_bus',
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              title: Text('Contact Driver'),
              subtitle: Text('Current trip driver'),
              onTap: () {
                Navigator.pop(context);
                // Handle contact driver
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.getWarningColor(
                          Theme.of(context).brightness == Brightness.light)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'support_agent',
                  color: AppTheme.getWarningColor(
                      Theme.of(context).brightness == Brightness.light),
                  size: 24,
                ),
              ),
              title: Text('Transportation Support'),
              subtitle: Text('+1 (555) 987-6543'),
              onTap: () {
                Navigator.pop(context);
                // Handle transportation support
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

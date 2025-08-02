import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FloatingActionButtonsWidget extends StatelessWidget {
  final VoidCallback onNavigate;
  final VoidCallback onSaveRoute;
  final VoidCallback onShareRoute;
  final bool isEditing;

  const FloatingActionButtonsWidget({
    super.key,
    required this.onNavigate,
    required this.onSaveRoute,
    required this.onShareRoute,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12.h,
      right: 4.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Share Route FAB
          FloatingActionButton(
            heroTag: "share_route",
            onPressed: onShareRoute,
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
            child: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onSecondary,
              size: 24,
            ),
          ),
          SizedBox(height: 2.h),
          // Save Route FAB (only visible in edit mode)
          if (isEditing) ...[
            FloatingActionButton(
              heroTag: "save_route",
              onPressed: onSaveRoute,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'save',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
            SizedBox(height: 2.h),
          ],
          // Navigate FAB
          FloatingActionButton.extended(
            heroTag: "navigate_route",
            onPressed: onNavigate,
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            icon: CustomIconWidget(
              iconName: 'navigation',
              color: AppTheme.lightTheme.colorScheme.onTertiary,
              size: 24,
            ),
            label: Text(
              'Navigate',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

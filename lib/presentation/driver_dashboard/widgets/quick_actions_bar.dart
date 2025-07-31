import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsBar extends StatelessWidget {
  final VoidCallback? onNavigationTap;
  final VoidCallback? onEmergencyTap;
  final VoidCallback? onRefreshTap;
  final VoidCallback? onSettingsTap;

  const QuickActionsBar({
    Key? key,
    this.onNavigationTap,
    this.onEmergencyTap,
    this.onRefreshTap,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: 'navigation',
              label: 'Navigation',
              color: AppTheme.lightTheme.colorScheme.primary,
              onTap: onNavigationTap,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildActionButton(
              icon: 'refresh',
              label: 'Refresh',
              color: AppTheme.getSuccessColor(true),
              onTap: onRefreshTap,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildActionButton(
              icon: 'settings',
              label: 'Settings',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              onTap: onSettingsTap,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildActionButton(
              icon: 'emergency',
              label: 'Emergency',
              color: AppTheme.lightTheme.colorScheme.error,
              onTap: onEmergencyTap,
              isEmergency: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool isEmergency = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: isEmergency
              ? color.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: isEmergency
              ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isEmergency
                    ? color.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 6.w,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isEmergency ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

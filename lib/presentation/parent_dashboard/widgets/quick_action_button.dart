import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconName;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const QuickActionButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.iconName,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color defaultBackgroundColor =
        isDarkMode ? AppTheme.cardDark : AppTheme.cardLight;
    final Color defaultIconColor =
        isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? defaultBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? AppTheme.shadowDark : AppTheme.shadowLight,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: (iconColor ?? defaultIconColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: iconColor ?? defaultIconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: isDarkMode
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

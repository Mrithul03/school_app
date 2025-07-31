import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notificationData;
  final VoidCallback? onDismiss;

  const NotificationCard({
    Key? key,
    required this.notificationData,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String title = notificationData['title'] as String? ?? 'Notification';
    final String message = notificationData['message'] as String? ?? '';
    final String time = notificationData['time'] as String? ?? '';
    final String type = notificationData['type'] as String? ?? 'info';
    final bool isRead = notificationData['isRead'] as bool? ?? false;

    Color _getNotificationColor() {
      switch (type.toLowerCase()) {
        case 'delay':
          return AppTheme.getWarningColor(!isDarkMode);
        case 'alert':
          return Theme.of(context).colorScheme.error;
        case 'success':
          return AppTheme.getSuccessColor(!isDarkMode);
        default:
          return isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight;
      }
    }

    IconData _getNotificationIcon() {
      switch (type.toLowerCase()) {
        case 'delay':
          return Icons.schedule;
        case 'alert':
          return Icons.warning;
        case 'success':
          return Icons.check_circle;
        case 'route':
          return Icons.route;
        default:
          return Icons.info;
      }
    }

    return Dismissible(
      key: Key('notification_${notificationData['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Dismiss',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'close',
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) {
        if (onDismiss != null) {
          onDismiss!();
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: !isRead
              ? Border.all(
                  color: _getNotificationColor().withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? AppTheme.shadowDark : AppTheme.shadowLight,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _getNotificationColor().withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: _getNotificationIcon().codePoint.toString(),
                color: _getNotificationColor(),
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight:
                                    isRead ? FontWeight.w500 : FontWeight.w600,
                                color: isDarkMode
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: _getNotificationColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (message.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (time.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDarkMode
                                ? AppTheme.textDisabledDark
                                : AppTheme.textDisabledLight,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

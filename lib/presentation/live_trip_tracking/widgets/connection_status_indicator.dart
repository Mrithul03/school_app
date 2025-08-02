import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  final bool isConnected;
  final String connectionType;
  final DateTime? lastUpdate;

  const ConnectionStatusIndicator({
    Key? key,
    required this.isConnected,
    this.connectionType = 'WiFi',
    this.lastUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8.h,
      left: 4.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isConnected
              ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.9)
              : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: isConnected
                    ? AppTheme.lightTheme.colorScheme.onSecondary
                    : AppTheme.lightTheme.colorScheme.onError,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              isConnected ? 'Live • $connectionType' : 'Offline',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isConnected
                    ? AppTheme.lightTheme.colorScheme.onSecondary
                    : AppTheme.lightTheme.colorScheme.onError,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isConnected && lastUpdate != null) ...[
              SizedBox(width: 2.w),
              Text(
                '• ${_formatLastUpdate()}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onError,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastUpdate() {
    if (lastUpdate == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastUpdate!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

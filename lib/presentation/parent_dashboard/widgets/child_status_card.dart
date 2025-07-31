import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChildStatusCard extends StatelessWidget {
  final Map<String, dynamic> childData;
  final VoidCallback? onTap;
  final VoidCallback? onContactDriver;
  final VoidCallback? onViewRoute;
  final VoidCallback? onTripHistory;

  const ChildStatusCard({
    Key? key,
    required this.childData,
    this.onTap,
    this.onContactDriver,
    this.onViewRoute,
    this.onTripHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String childName = childData['name'] as String? ?? 'Unknown Child';
    final String status = childData['status'] as String? ?? 'Unknown';
    final String estimatedTime =
        childData['estimatedTime'] as String? ?? '--:--';
    final String photoUrl = childData['photoUrl'] as String? ?? '';
    final String grade = childData['grade'] as String? ?? '';

    Color _getStatusColor() {
      switch (status.toLowerCase()) {
        case 'picked up':
          return AppTheme.getSuccessColor(!isDarkMode);
        case 'in transit':
          return isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight;
        case 'dropped off':
          return AppTheme.getSuccessColor(!isDarkMode);
        case 'waiting':
          return AppTheme.getWarningColor(!isDarkMode);
        default:
          return isDarkMode
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight;
      }
    }

    IconData _getStatusIcon() {
      switch (status.toLowerCase()) {
        case 'picked up':
          return Icons.person_add;
        case 'in transit':
          return Icons.directions_bus;
        case 'dropped off':
          return Icons.home;
        case 'waiting':
          return Icons.schedule;
        default:
          return Icons.help_outline;
      }
    }

    return Dismissible(
      key: Key('child_${childData['id']}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'phone',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Contact Driver',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
      onDismissed: (direction) {
        if (onContactDriver != null) {
          onContactDriver!();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
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
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getStatusColor(),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? CustomImageWidget(
                          imageUrl: photoUrl,
                          width: 15.w,
                          height: 15.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: (isDarkMode
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight)
                              .withValues(alpha: 0.1),
                          child: CustomIconWidget(
                            iconName: 'person',
                            color: isDarkMode
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                            size: 8.w,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            childName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? AppTheme.textPrimaryDark
                                      : AppTheme.textPrimaryLight,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (grade.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: (isDarkMode
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              grade,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
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
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _getStatusColor(),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    if (estimatedTime != '--:--') ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        'ETA: $estimatedTime',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                      ),
                    ],
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
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
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
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('Set Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Handle set notifications
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('Share Location'),
              onTap: () {
                Navigator.pop(context);
                // Handle share location
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                // Handle report issue
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

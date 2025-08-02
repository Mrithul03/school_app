import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapFloatingButtons extends StatelessWidget {
  final VoidCallback? onCallDriver;
  final VoidCallback? onMessageDriver;
  final VoidCallback? onShareLocation;
  final VoidCallback? onMyLocation;

  const MapFloatingButtons({
    Key? key,
    this.onCallDriver,
    this.onMessageDriver,
    this.onShareLocation,
    this.onMyLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // My Location Button (Bottom Right)
        Positioned(
          bottom: 25.h,
          right: 4.w,
          child: _buildFloatingButton(
            icon: 'my_location',
            onTap: onMyLocation,
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            iconColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),

        // Action Buttons (Top Right)
        Positioned(
          top: 12.h,
          right: 4.w,
          child: Column(
            children: [
              _buildFloatingButton(
                icon: 'phone',
                onTap: onCallDriver,
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                iconColor: AppTheme.lightTheme.colorScheme.onSecondary,
                tooltip: 'Call Driver',
              ),
              SizedBox(height: 2.h),
              _buildFloatingButton(
                icon: 'message',
                onTap: onMessageDriver,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                iconColor: AppTheme.lightTheme.colorScheme.onPrimary,
                tooltip: 'Message Driver',
              ),
              SizedBox(height: 2.h),
              _buildFloatingButton(
                icon: 'share',
                onTap: onShareLocation,
                backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                iconColor: AppTheme.lightTheme.colorScheme.onTertiary,
                tooltip: 'Share Location',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required String icon,
    required VoidCallback? onTap,
    required Color backgroundColor,
    required Color iconColor,
    String? tooltip,
  }) {
    Widget button = Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
      ),
    );

    return tooltip != null
        ? Tooltip(
            message: tooltip,
            child: button,
          )
        : button;
  }
}

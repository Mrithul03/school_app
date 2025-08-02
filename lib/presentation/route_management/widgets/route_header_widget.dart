import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteHeaderWidget extends StatelessWidget {
  final String selectedRoute;
  final List<String> availableRoutes;
  final Function(String) onRouteChanged;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final VoidCallback onSaveRoute;

  const RouteHeaderWidget({
    super.key,
    required this.selectedRoute,
    required this.availableRoutes,
    required this.onRouteChanged,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onSaveRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRoute,
                  isExpanded: true,
                  items: availableRoutes.map((String route) {
                    return DropdownMenuItem<String>(
                      value: route,
                      child: Text(
                        route,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onRouteChanged(newValue);
                    }
                  },
                  icon: CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          TextButton.icon(
            onPressed: onToggleEdit,
            icon: CustomIconWidget(
              iconName: isEditing ? 'close' : 'edit',
              color: isEditing
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.primary,
              size: 18,
            ),
            label: Text(
              isEditing ? 'Cancel' : 'Edit',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isEditing
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isEditing) ...[
            SizedBox(width: 2.w),
            ElevatedButton.icon(
              onPressed: onSaveRoute,
              icon: CustomIconWidget(
                iconName: 'save',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 18,
              ),
              label: Text('Save'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

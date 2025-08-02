import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteDetailsSheetWidget extends StatefulWidget {
  final Map<String, dynamic> routeInfo;
  final List<Map<String, dynamic>> stops;
  final bool isEditing;
  final Function(List<Map<String, dynamic>>) onReorderStops;
  final Function(int, String) onEditStopTime;
  final Function(int, String) onAddStopNote;
  final Function(int) onSkipStop;
  final Function(int) onContactParents;
  final VoidCallback onShareRoute;

  const RouteDetailsSheetWidget({
    super.key,
    required this.routeInfo,
    required this.stops,
    required this.isEditing,
    required this.onReorderStops,
    required this.onEditStopTime,
    required this.onAddStopNote,
    required this.onSkipStop,
    required this.onContactParents,
    required this.onShareRoute,
  });

  @override
  State<RouteDetailsSheetWidget> createState() =>
      _RouteDetailsSheetWidgetState();
}

class _RouteDetailsSheetWidgetState extends State<RouteDetailsSheetWidget> {
  double _sheetHeight = 0.3;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _sheetHeight,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 1.h),
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with route summary
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route Summary',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              _buildSummaryItem(
                                icon: 'straighten',
                                label: widget.routeInfo['totalDistance'] ??
                                    '12.5 km',
                              ),
                              SizedBox(width: 4.w),
                              _buildSummaryItem(
                                icon: 'schedule',
                                label: widget.routeInfo['estimatedTime'] ??
                                    '45 min',
                              ),
                              SizedBox(width: 4.w),
                              _buildSummaryItem(
                                icon: 'people',
                                label: '${widget.stops.length} stops',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onShareRoute,
                      icon: CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Scrollable content
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: widget.stops.length,
                  itemBuilder: (context, index) {
                    final stop = widget.stops[index];
                    return _buildStopItem(stop, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem({required String icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 16,
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStopItem(Map<String, dynamic> stop, int index) {
    return Dismissible(
      key: Key('stop_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: 'schedule',
              label: 'Edit Time',
              onTap: () => _showEditTimeDialog(index),
            ),
            SizedBox(width: 2.w),
            _buildActionButton(
              icon: 'note_add',
              label: 'Add Note',
              onTap: () => _showAddNoteDialog(index),
            ),
            SizedBox(width: 2.w),
            _buildActionButton(
              icon: 'skip_next',
              label: 'Skip',
              onTap: () => widget.onSkipStop(index),
            ),
            SizedBox(width: 2.w),
            _buildActionButton(
              icon: 'phone',
              label: 'Contact',
              onTap: () => widget.onContactParents(index),
            ),
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Stop number and status
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: _getStopStatusColor(stop['status']),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Stop details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop['address'] ?? 'Unknown Address',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'people',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${(stop['students'] as List).length} students',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        stop['timeWindow'] ?? '8:00-8:05 AM',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (stop['notes'] != null &&
                      (stop['notes'] as String).isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      stop['notes'],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Reorder handle (only in edit mode)
            if (widget.isEditing)
              CustomIconWidget(
                iconName: 'drag_handle',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStopStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'current':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'delayed':
        return AppTheme.lightTheme.colorScheme.error;
      case 'skipped':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showEditTimeDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Time Window'),
        content: TextField(
          decoration: InputDecoration(
            labelText: 'Time Window (e.g., 8:00-8:05 AM)',
            hintText: widget.stops[index]['timeWindow'],
          ),
          onSubmitted: (value) {
            widget.onEditStopTime(index, value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note'),
        content: TextField(
          decoration: InputDecoration(
            labelText: 'Special Instructions',
            hintText: 'Enter note for this stop...',
          ),
          maxLines: 3,
          onSubmitted: (value) {
            widget.onAddStopNote(index, value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

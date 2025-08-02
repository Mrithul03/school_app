import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TripInfoBottomSheet extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final VoidCallback? onCallDriver;
  final VoidCallback? onMessageDriver;

  const TripInfoBottomSheet({
    Key? key,
    required this.tripData,
    this.onCallDriver,
    this.onMessageDriver,
  }) : super(key: key);

  @override
  State<TripInfoBottomSheet> createState() => _TripInfoBottomSheetState();
}

class _TripInfoBottomSheetState extends State<TripInfoBottomSheet> {
  double _sheetHeight = 0.15;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _sheetHeight,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              _buildDragHandle(),
              _buildCollapsedContent(),
              if (_isExpanded) _buildExpandedContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Center(
        child: Container(
          width: 10.w,
          height: 0.5.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundImage: NetworkImage(widget.tripData['driverPhoto'] ??
                    'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tripData['driverName'] ?? 'John Smith',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Vehicle: ${widget.tripData['vehicleNumber'] ?? 'BUS-001'}',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildQuickActionButton(
                icon: 'phone',
                onTap: widget.onCallDriver,
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
              SizedBox(width: 2.w),
              _buildQuickActionButton(
                icon: 'message',
                onTap: widget.onMessageDriver,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem(
                'Speed',
                '${widget.tripData['currentSpeed'] ?? '45'} mph',
                'speed',
              ),
              _buildStatusItem(
                'Next Stop',
                widget.tripData['nextStop'] ?? 'Oak Street',
                'location_on',
              ),
              _buildStatusItem(
                'Students',
                '${widget.tripData['studentCount'] ?? '12'}',
                'people',
              ),
            ],
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                _sheetHeight = _isExpanded ? 0.85 : 0.15;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? 'Show Less' : 'View Details',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: _isExpanded
                        ? 'keyboard_arrow_up'
                        : 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    final List<Map<String, dynamic>> students = [
      {
        'name': 'Emma Johnson',
        'grade': '5th Grade',
        'status': 'On Board',
        'pickupTime': '7:45 AM',
        'photo':
            'https://images.pexels.com/photos/3771074/pexels-photo-3771074.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      },
      {
        'name': 'Michael Chen',
        'grade': '4th Grade',
        'status': 'On Board',
        'pickupTime': '7:50 AM',
        'photo':
            'https://images.pexels.com/photos/3771071/pexels-photo-3771071.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      },
      {
        'name': 'Sofia Rodriguez',
        'grade': '6th Grade',
        'status': 'Waiting',
        'pickupTime': '8:00 AM',
        'photo':
            'https://images.pexels.com/photos/3771069/pexels-photo-3771069.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppTheme.lightTheme.colorScheme.outline),
          SizedBox(height: 2.h),
          Text(
            'Trip Details',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
              'Route', widget.tripData['routeName'] ?? 'Morning Route A'),
          _buildDetailRow(
              'Departure Time', widget.tripData['departureTime'] ?? '7:30 AM'),
          _buildDetailRow('Estimated Arrival',
              widget.tripData['estimatedArrival'] ?? '8:15 AM'),
          _buildDetailRow('Distance Remaining',
              widget.tripData['distanceRemaining'] ?? '2.3 miles'),
          SizedBox(height: 3.h),
          Text(
            'Students on Board',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentItem(student);
            },
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> student) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 5.w,
            backgroundImage: NetworkImage(student['photo']),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  student['grade'],
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: student['status'] == 'On Board'
                      ? AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student['status'],
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: student['status'] == 'On Board'
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                student['pickupTime'],
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onMarkPresent;
  final VoidCallback? onMarkAbsent;
  final VoidCallback? onContactParent;
  final VoidCallback? onViewNotes;
  final VoidCallback? onEmergencyContact;

  const StudentCard({
    Key? key,
    required this.student,
    this.onToggleStatus,
    this.onMarkPresent,
    this.onMarkAbsent,
    this.onContactParent,
    this.onViewNotes,
    this.onEmergencyContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPresent = student['isPresent'] ?? false;
    final bool hasSpecialNotes =
        (student['specialNotes'] as String?)?.isNotEmpty ?? false;
    // final bool hasMedicalAlert = student['hasMedicalAlert'] ?? false;
    final String student_name = student['student_name'] as String? ?? 'N/A';

// Function to launch phone dialer
    void _callParent(String phoneNumber) async {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $phoneNumber';
      }
    }

    return Dismissible(
      key: Key('student_${student['id']}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          color: AppTheme.getSuccessColor(true),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Mark Present',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (onMarkPresent != null) onMarkPresent!();
      },
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPresent
                  ? AppTheme.getSuccessColor(true).withValues(alpha: 0.3)
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPresent
                            ? AppTheme.getSuccessColor(true)
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.w),
                      child: CustomImageWidget(
                        imageUrl:
                            'https://cdn-icons-png.flaticon.com/512/3135/3135715.png', // dummy student icon
                        width: 15.w,
                        height: 15.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // if (hasMedicalAlert)
                  //   Positioned(
                  //     top: 0,
                  //     right: 0,
                  //     child: Container(
                  //       padding: EdgeInsets.all(1.w),
                  //       decoration: BoxDecoration(
                  //         color: AppTheme.lightTheme.colorScheme.error,
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: CustomIconWidget(
                  //         iconName: 'medical_services',
                  //         color: Colors.white,
                  //         size: 3.w,
                  //       ),
                  //     ),
                  //   ),
                ],
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
                            student['student_name'] ?? 'Student Options',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasSpecialNotes)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.getWarningColor(true)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: 'note',
                              color: AppTheme.getWarningColor(true),
                              size: 3.w,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'phone',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            student['student_phone'] ??
                                'No phone number available',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    // Row(
                    //   children: [
                    //     Container(
                    //       padding: EdgeInsets.symmetric(
                    //           horizontal: 2.w, vertical: 0.5.h),
                    //       decoration: BoxDecoration(
                    //         color: isPresent
                    //             ? AppTheme.getSuccessColor(true)
                    //                 .withValues(alpha: 0.1)
                    //             : AppTheme.lightTheme.colorScheme.outline
                    //                 .withValues(alpha: 0.1),
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       child: Text(
                    //         isPresent ? 'Present' : 'Not Checked In',
                    //         style: AppTheme.lightTheme.textTheme.labelSmall
                    //             ?.copyWith(
                    //           color: isPresent
                    //               ? AppTheme.getSuccessColor(true)
                    //               : AppTheme
                    //                   .lightTheme.colorScheme.onSurfaceVariant,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     ),
                    //     Spacer(),
                    //     Text(
                    //       'Grade ${student['grade'] ?? 'N/A'}',
                    //       style: AppTheme.lightTheme.textTheme.labelSmall
                    //           ?.copyWith(
                    //         color: AppTheme
                    //             .lightTheme.colorScheme.onSurfaceVariant,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    InkWell(
                      onTap: () {
                        if (student['student_phone'] != null &&
                            student['student_phone'].toString().isNotEmpty) {
                          _callParent(student['student_phone']);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.call,
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 18,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Call Parent',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              // GestureDetector(
              //   onTap: onToggleStatus,
              //   child: Container(
              //     width: 12.w,
              //     height: 6.h,
              //     decoration: BoxDecoration(
              //       color: isPresent
              //           ? AppTheme.getSuccessColor(true)
              //           : AppTheme.lightTheme.colorScheme.outline,
              //       borderRadius: BorderRadius.circular(25),
              //     ),
              //     child: AnimatedAlign(
              //       duration: Duration(milliseconds: 200),
              //       alignment: isPresent
              //           ? Alignment.centerRight
              //           : Alignment.centerLeft,
              //       child: Container(
              //         width: 5.w,
              //         height: 5.w,
              //         margin: EdgeInsets.all(1.w),
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           shape: BoxShape.circle,
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black.withValues(alpha: 0.2),
              //               blurRadius: 4,
              //               offset: Offset(0, 2),
              //             ),
              //           ],
              //         ),
              //         child: CustomIconWidget(
              //           iconName: isPresent ? 'check' : 'close',
              //           color: isPresent
              //               ? AppTheme.getSuccessColor(true)
              //               : AppTheme.lightTheme.colorScheme.outline,
              //           size: 3.w,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
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
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              student['student_name'] ?? 'Student Options',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildMenuOption(
              context,
              icon: 'check_circle',
              title: 'Mark Present',
              onTap: onMarkPresent,
              color: AppTheme.getSuccessColor(true),
            ),
            _buildMenuOption(
              context,
              icon: 'cancel',
              title: 'Mark Absent',
              onTap: onMarkAbsent,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            _buildMenuOption(
              context,
              icon: 'phone',
              title: 'Contact Parent',
              onTap: onContactParent,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            _buildMenuOption(
              context,
              icon: 'note',
              title: 'Special Notes',
              onTap: onViewNotes,
              color: AppTheme.getWarningColor(true),
            ),
            _buildMenuOption(
              context,
              icon: 'emergency',
              title: 'Emergency Contact',
              onTap: onEmergencyContact,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: color,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) onTap();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

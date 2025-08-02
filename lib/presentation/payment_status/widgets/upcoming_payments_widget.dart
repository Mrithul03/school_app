import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UpcomingPaymentsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> upcomingPayments;
  final Function(Map<String, dynamic>)? onSchedulePayment;

  const UpcomingPaymentsWidget({
    Key? key,
    required this.upcomingPayments,
    this.onSchedulePayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppTheme.dividerDark : AppTheme.dividerLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color:
                    isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Upcoming Payments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount:
                upcomingPayments.length > 3 ? 3 : upcomingPayments.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final payment = upcomingPayments[index];
              final bool isNextPayment = index == 0;

              return Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isNextPayment
                      ? (isDarkMode
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight)
                          .withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isNextPayment
                      ? Border.all(
                          color: isDarkMode
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight,
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: isNextPayment
                            ? (isDarkMode
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight)
                            : (isDarkMode
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight)
                                .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'calendar_today',
                        color: isNextPayment
                            ? Colors.white
                            : isDarkMode
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                payment['month'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isNextPayment
                                          ? (isDarkMode
                                              ? AppTheme.primaryDark
                                              : AppTheme.primaryLight)
                                          : null,
                                    ),
                              ),
                              Text(
                                payment['amount'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isNextPayment
                                          ? (isDarkMode
                                              ? AppTheme.primaryDark
                                              : AppTheme.primaryLight)
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Due: ${payment['dueDate'] as String}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                              ),
                              if (isNextPayment)
                                GestureDetector(
                                  onTap: () => onSchedulePayment?.call(payment),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? AppTheme.primaryDark
                                          : AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Schedule',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (upcomingPayments.length > 3) ...[
            SizedBox(height: 1.h),
            Center(
              child: TextButton(
                onPressed: () {
                  // Show all upcoming payments
                },
                child: Text(
                  'View All (${upcomingPayments.length})',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

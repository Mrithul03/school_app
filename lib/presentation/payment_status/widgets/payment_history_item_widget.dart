import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentHistoryItemWidget extends StatelessWidget {
  final Map<String, dynamic> paymentItem;
  final VoidCallback? onTap;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onDispute;
  final VoidCallback? onSetReminder;

  const PaymentHistoryItemWidget({
    Key? key,
    required this.paymentItem,
    this.onTap,
    this.onViewReceipt,
    this.onDispute,
    this.onSetReminder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String status = paymentItem['status'] as String;
    final Color statusColor = _getStatusColor(status, isDarkMode);

    return Dismissible(
      key: Key(paymentItem['id'].toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'receipt',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'report_problem',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'notifications',
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        _showActionBottomSheet(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          onTap: onTap,
          leading: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getPaymentMethodIcon(paymentItem['method'] as String),
              color: statusColor,
              size: 20,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  paymentItem['date'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                paymentItem['amount'] as String,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    paymentItem['method'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: CustomIconWidget(
            iconName: 'download',
            color: isDarkMode
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'receipt',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('View Receipt'),
              onTap: () {
                Navigator.pop(context);
                onViewReceipt?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report_problem',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: Text('Dispute Charge'),
              onTap: () {
                Navigator.pop(context);
                onDispute?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('Set Reminder'),
              onTap: () {
                Navigator.pop(context);
                onSetReminder?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return isDarkMode ? AppTheme.successDark : AppTheme.successLight;
      case 'pending':
        return isDarkMode ? AppTheme.warningDark : AppTheme.warningLight;
      case 'failed':
      case 'overdue':
        return isDarkMode ? AppTheme.errorDark : AppTheme.errorLight;
      default:
        return isDarkMode
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight;
    }
  }

  String _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
      case 'debit card':
        return 'credit_card';
      case 'bank transfer':
        return 'account_balance';
      case 'apple pay':
        return 'phone_iphone';
      case 'google pay':
        return 'phone_android';
      case 'paypal':
        return 'payment';
      default:
        return 'payment';
    }
  }
}

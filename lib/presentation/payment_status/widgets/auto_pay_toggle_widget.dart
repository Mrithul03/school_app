import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AutoPayToggleWidget extends StatefulWidget {
  final bool isEnabled;
  final String? paymentMethod;
  final VoidCallback? onToggle;
  final VoidCallback? onManagePaymentMethods;

  const AutoPayToggleWidget({
    Key? key,
    required this.isEnabled,
    this.paymentMethod,
    this.onToggle,
    this.onManagePaymentMethods,
  }) : super(key: key);

  @override
  State<AutoPayToggleWidget> createState() => _AutoPayToggleWidgetState();
}

class _AutoPayToggleWidgetState extends State<AutoPayToggleWidget> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
  }

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
                iconName: 'autorenew',
                color:
                    isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Pay',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Automatically pay monthly fees',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                  widget.onToggle?.call();
                },
              ),
            ],
          ),
          if (_isEnabled) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color:
                    (isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'security',
                        color: isDarkMode
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Secure Payment Method',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: _getPaymentMethodIcon(
                            widget.paymentMethod ?? 'Credit Card'),
                        color: isDarkMode
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          widget.paymentMethod ?? 'No payment method selected',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onManagePaymentMethods,
                        child: Text(
                          'Manage',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color:
                    (isDarkMode ? AppTheme.warningDark : AppTheme.warningLight)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: isDarkMode
                        ? AppTheme.warningDark
                        : AppTheme.warningLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Payments will be processed 3 days before due date. You\'ll receive confirmation notifications.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppTheme.warningDark
                                : AppTheme.warningLight,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
        return 'credit_card';
    }
  }
}

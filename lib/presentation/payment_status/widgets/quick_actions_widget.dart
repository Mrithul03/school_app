import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback? onAddPaymentMethod;
  final VoidCallback? onDownloadTaxSummary;
  final VoidCallback? onContactSupport;

  const QuickActionsWidget({
    Key? key,
    this.onAddPaymentMethod,
    this.onDownloadTaxSummary,
    this.onContactSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: 'add_card',
                  title: 'Add Payment\nMethod',
                  color:
                      isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
                  onTap: onAddPaymentMethod,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: 'download',
                  title: 'Tax\nSummary',
                  color: isDarkMode
                      ? AppTheme.secondaryDark
                      : AppTheme.secondaryLight,
                  onTap: onDownloadTaxSummary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: 'support_agent',
                  title: 'Billing\nSupport',
                  color:
                      isDarkMode ? AppTheme.accentDark : AppTheme.accentLight,
                  onTap: onContactSupport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? AppTheme.shadowDark : AppTheme.shadowLight,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

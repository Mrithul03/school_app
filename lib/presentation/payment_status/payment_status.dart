import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/auto_pay_toggle_widget.dart';
import './widgets/payment_history_item_widget.dart';
import './widgets/payment_status_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/upcoming_payments_widget.dart';

class PaymentStatus extends StatefulWidget {
  const PaymentStatus({Key? key}) : super(key: key);

  @override
  State<PaymentStatus> createState() => _PaymentStatusState();
}

class _PaymentStatusState extends State<PaymentStatus>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isAutoPayEnabled = true;

  // Mock data for current payment status
  final Map<String, dynamic> currentPaymentData = {
    "status": "Paid",
    "amount": "\$150.00",
    "dueDate": "Jan 15, 2025",
    "paymentMethod": "Credit Card ****1234",
    "month": "January 2025"
  };

  // Mock data for payment history
  final List<Map<String, dynamic>> paymentHistory = [
    {
      "id": 1,
      "date": "Dec 15, 2024",
      "amount": "\$150.00",
      "method": "Credit Card",
      "status": "Completed",
      "receiptId": "RCP-2024-12-001"
    },
    {
      "id": 2,
      "date": "Nov 15, 2024",
      "amount": "\$150.00",
      "method": "Bank Transfer",
      "status": "Completed",
      "receiptId": "RCP-2024-11-001"
    },
    {
      "id": 3,
      "date": "Oct 15, 2024",
      "amount": "\$150.00",
      "method": "Apple Pay",
      "status": "Completed",
      "receiptId": "RCP-2024-10-001"
    },
    {
      "id": 4,
      "date": "Sep 15, 2024",
      "amount": "\$150.00",
      "method": "Credit Card",
      "status": "Failed",
      "receiptId": "RCP-2024-09-001"
    },
    {
      "id": 5,
      "date": "Aug 15, 2024",
      "amount": "\$150.00",
      "method": "Google Pay",
      "status": "Completed",
      "receiptId": "RCP-2024-08-001"
    }
  ];

  // Mock data for upcoming payments
  final List<Map<String, dynamic>> upcomingPayments = [
    {
      "month": "February 2025",
      "amount": "\$150.00",
      "dueDate": "Feb 15, 2025",
      "estimatedCost": "\$150.00"
    },
    {
      "month": "March 2025",
      "amount": "\$150.00",
      "dueDate": "Mar 15, 2025",
      "estimatedCost": "\$150.00"
    },
    {
      "month": "April 2025",
      "amount": "\$150.00",
      "dueDate": "Apr 15, 2025",
      "estimatedCost": "\$150.00"
    },
    {
      "month": "May 2025",
      "amount": "\$150.00",
      "dueDate": "May 15, 2025",
      "estimatedCost": "\$150.00"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Status'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: isDarkMode ? Colors.white : Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'notifications',
              color: isDarkMode ? Colors.white : Colors.white,
              size: 24,
            ),
            onPressed: () {
              _showNotificationSettings();
            },
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: isDarkMode ? Colors.white : Colors.white,
              size: 24,
            ),
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'account_balance_wallet',
                color:
                    isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 20,
              ),
              text: 'Overview',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'history',
                color:
                    isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 20,
              ),
              text: 'History',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'settings',
                color:
                    isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 20,
              ),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          PaymentStatusCardWidget(
            paymentData: currentPaymentData,
          ),
          SizedBox(height: 2.h),
          UpcomingPaymentsWidget(
            upcomingPayments: upcomingPayments,
            onSchedulePayment: (payment) {
              _showSchedulePaymentDialog(payment);
            },
          ),
          SizedBox(height: 2.h),
          QuickActionsWidget(
            onAddPaymentMethod: () {
              _showAddPaymentMethodDialog();
            },
            onDownloadTaxSummary: () {
              _downloadTaxSummary();
            },
            onContactSupport: () {
              _contactBillingSupport();
            },
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showFilterOptions();
                },
                icon: CustomIconWidget(
                  iconName: 'filter_list',
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
                label: Text('Filter'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: paymentHistory.length,
            itemBuilder: (context, index) {
              final payment = paymentHistory[index];
              return PaymentHistoryItemWidget(
                paymentItem: payment,
                onTap: () {
                  _showPaymentDetails(payment);
                },
                onViewReceipt: () {
                  _viewReceipt(payment);
                },
                onDispute: () {
                  _disputeCharge(payment);
                },
                onSetReminder: () {
                  _setReminder(payment);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          AutoPayToggleWidget(
            isEnabled: _isAutoPayEnabled,
            paymentMethod: currentPaymentData['paymentMethod'] as String?,
            onToggle: () {
              setState(() {
                _isAutoPayEnabled = !_isAutoPayEnabled;
              });
            },
            onManagePaymentMethods: () {
              _managePaymentMethods();
            },
          ),
          SizedBox(height: 2.h),
          _buildNotificationSettings(),
          SizedBox(height: 2.h),
          _buildBillingPreferences(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
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
                iconName: 'notifications',
                color:
                    isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Notification Preferences',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildNotificationOption('Payment Due Reminders', true),
          _buildNotificationOption('Payment Confirmations', true),
          _buildNotificationOption('Failed Payment Alerts', true),
          _buildNotificationOption('Monthly Statements', false),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String title, bool isEnabled) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // Handle notification preference change
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillingPreferences() {
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
                iconName: 'receipt_long',
                color:
                    isDarkMode ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Billing Preferences',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Email Receipts'),
            subtitle: Text('parent@email.com'),
            trailing: CustomIconWidget(
              iconName: 'edit',
              color: isDarkMode
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
            onTap: () {
              _editEmailAddress();
            },
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Billing Address'),
            subtitle: Text('123 Main St, City, State 12345'),
            trailing: CustomIconWidget(
              iconName: 'edit',
              color: isDarkMode
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
            onTap: () {
              _editBillingAddress();
            },
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Tax Information'),
            subtitle: Text('Download annual tax documents'),
            trailing: CustomIconWidget(
              iconName: 'download',
              color: isDarkMode
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
            onTap: () {
              _downloadTaxDocuments();
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notification Settings'),
        content: Text('Configure your payment notification preferences.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
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
            ListTile(
              leading: CustomIconWidget(
                iconName: 'help',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                _showHelpSupport();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('Share Payment Summary'),
              onTap: () {
                Navigator.pop(context);
                _sharePaymentSummary();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'print',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('Print Statement'),
              onTap: () {
                Navigator.pop(context);
                _printStatement();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSchedulePaymentDialog(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedule payment for ${payment['month']}?'),
            SizedBox(height: 1.h),
            Text('Amount: ${payment['amount']}'),
            Text('Due Date: ${payment['dueDate']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle schedule payment
            },
            child: Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Payment Method'),
        content: Text('Add a new payment method for automatic payments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle add payment method
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _downloadTaxSummary() {
    // Handle tax summary download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tax summary downloaded successfully')),
    );
  }

  void _contactBillingSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Billing Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'phone',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('Call Support'),
              subtitle: Text('1-800-SCHOOL-1'),
              onTap: () {
                Navigator.pop(context);
                // Handle phone call
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              title: Text('Email Support'),
              subtitle: Text('billing@schooltrip.com'),
              onTap: () {
                Navigator.pop(context);
                // Handle email
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
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
            Text(
              'Filter Payments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              title: Text('All Payments'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Completed Only'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Failed Only'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Last 6 Months'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${payment['date']}'),
            Text('Amount: ${payment['amount']}'),
            Text('Method: ${payment['method']}'),
            Text('Status: ${payment['status']}'),
            Text('Receipt ID: ${payment['receiptId']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewReceipt(Map<String, dynamic> payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Receipt downloaded for ${payment['receiptId']}')),
    );
  }

  void _disputeCharge(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dispute Charge'),
        content: Text('Are you sure you want to dispute this charge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dispute submitted successfully')),
              );
            },
            child: Text('Submit Dispute'),
          ),
        ],
      ),
    );
  }

  void _setReminder(Map<String, dynamic> payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for payment follow-up')),
    );
  }

  void _managePaymentMethods() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Payment Methods'),
        content: Text('View and manage your saved payment methods.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editEmailAddress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Email Address'),
        content: TextField(
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter your email address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Email address updated successfully')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBillingAddress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Billing Address'),
        content: Text('Update your billing address information.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Billing address updated successfully')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _downloadTaxDocuments() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tax documents downloaded successfully')),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Text('Access help documentation and support resources.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sharePaymentSummary() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment summary shared successfully')),
    );
  }

  void _printStatement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Statement sent to printer')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String phone, String password, String schoolCode, String role) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolCodeController = TextEditingController();

  bool _isPasswordVisible = false;
  String _selectedRole = 'Parent';
  String? _phoneError;
  String? _passwordError;
  String? _schoolCodeError;

  final List<String> _roles = ['Parent', 'Driver', 'Admin'];

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _schoolCodeController.dispose();
    super.dispose();
  }

  void _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        _phoneError = 'Enter a valid 10-digit phone number';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateSchoolCode(String value) {
    setState(() {
      if (value.isEmpty) {
        _schoolCodeError = 'School code is required';
      } else if (value.length < 4) {
        _schoolCodeError = 'School code must be at least 4 characters';
      } else {
        _schoolCodeError = null;
      }
    });
  }

  bool get _isFormValid {
    return _phoneError == null &&
        _passwordError == null &&
        _schoolCodeError == null &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _schoolCodeController.text.isNotEmpty;
  }

  void _handleLogin() {
    if (_isFormValid && !widget.isLoading) {
      widget.onLogin(
        _phoneController.text.trim(),
        _passwordController.text,
        _schoolCodeController.text.trim(),
        _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // School Code
          Text('School Code', style: AppTheme.lightTheme.textTheme.titleSmall),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _schoolCodeController,
            onChanged: _validateSchoolCode,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'Enter school code',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'school',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('QR Scanner feature coming soon'),
                            backgroundColor: AppTheme.getWarningColor(true),
                          ),
                        );
                      },
                icon: CustomIconWidget(
                  iconName: 'qr_code_scanner',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              errorText: _schoolCodeError,
            ),
          ),
          SizedBox(height: 3.h),

          // Phone Number
          Text('Phone Number', style: AppTheme.lightTheme.textTheme.titleSmall),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onChanged: _validatePhone,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'call',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              errorText: _phoneError,
            ),
          ),
          SizedBox(height: 3.h),

          // Password
          Text('Password', style: AppTheme.lightTheme.textTheme.titleSmall),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            onChanged: _validatePassword,
            onFieldSubmitted: (_) => _handleLogin(),
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                icon: CustomIconWidget(
                  iconName:
                      _isPasswordVisible ? 'visibility_off' : 'visibility',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              errorText: _passwordError,
            ),
          ),
          SizedBox(height: 2.h),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Password reset link sent to your phone'),
                          backgroundColor: AppTheme.getSuccessColor(true),
                        ),
                      );
                    },
              child: Text(
                'Forgot Password?',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Role Selector
          Text('Select Your Role',
              style: AppTheme.lightTheme.textTheme.titleSmall),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: _roles.map((role) {
              final isSelected = _selectedRole == role;
              return ChoiceChip(
                label: Text(role),
                selected: isSelected,
                onSelected: widget.isLoading
                    ? null
                    : (selected) {
                        if (selected) {
                          setState(() {
                            _selectedRole = role;
                          });
                        }
                      },
                selectedColor:
                    AppTheme.lightTheme.primaryColor.withAlpha(50),
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 4.h),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isFormValid && !widget.isLoading ? _handleLogin : null,
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Signing In...',
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Sign In',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

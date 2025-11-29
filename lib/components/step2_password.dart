import 'package:app_tact/colors.dart';
import 'package:app_tact/components/login_button.dart';
import 'package:app_tact/components/login_input.dart';
import 'package:app_tact/components/logo_and_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Step2Password extends StatefulWidget {
  final String initialPassword;
  final Function(String password) onNext;
  final VoidCallback onBack;

  const Step2Password({
    super.key,
    required this.initialPassword,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2Password> createState() => _Step2PasswordState();
}

class _Step2PasswordState extends State<Step2Password> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _hasPasswordError = false;
  bool _hasConfirmPasswordError = false;
  bool _hasPasswordText = false;
  bool _hasConfirmPasswordText = false;
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _passwordController.text = widget.initialPassword;
    _hasPasswordText = widget.initialPassword.isNotEmpty;
    _checkPasswordStrength(widget.initialPassword);

    _passwordController.addListener(() {
      setState(() {
        _hasPasswordText = _passwordController.text.isNotEmpty;
        _checkPasswordStrength(_passwordController.text);
      });
    });

    _confirmPasswordController.addListener(() {
      setState(() {
        _hasConfirmPasswordText = _confirmPasswordController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      _passwordStrength = '';
      _strengthColor = Colors.grey;
      return;
    }

    bool hasMinLength = password.length >= 6;
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int score = 0;

    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasSpecialChar) score++;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;

    setState(() {
      if (!hasMinLength || !hasUppercase || !hasSpecialChar) {
        _passwordStrength = 'Weak';
        _strengthColor = Colors.red;
      } else if (score < 5) {
        _passwordStrength = 'Medium';
        _strengthColor = Colors.orange;
      } else if (score < 6) {
        _passwordStrength = 'Strong';
        _strengthColor = Colors.green;
      } else {
        _passwordStrength = 'Very Strong';
        _strengthColor = Colors.green[700]!;
      }
    });
  }

  void _handleNext() {
    setState(() {
      _hasPasswordError = false;
      _hasConfirmPasswordError = false;
    });

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _hasPasswordError = true;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _hasPasswordError = true;
      });
      return;
    }

    if (!_passwordController.text.contains(RegExp(r'[A-Z]'))) {
      setState(() {
        _hasPasswordError = true;
      });
      return;
    }

    if (!_passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() {
        _hasPasswordError = true;
      });
      return;
    }

    if (_confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _hasConfirmPasswordError = true;
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _hasConfirmPasswordError = true;
      });
      return;
    }

    widget.onNext(_passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0B0E1D), Color(0xFF2E2939)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LogoAndTitle(
                            title: "Create a password",
                            subtitle: "Make it strong and secure",
                          ),
                          SizedBox(height: 32.h),
                          LoginInput(
                            type: "password",
                            controller: _passwordController,
                            hasError: _hasPasswordError,
                            hasText: _hasPasswordText,
                          ),
                          if (_hasPasswordText &&
                              _passwordStrength.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Text(
                                  'Password strength: ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Text(
                                  _passwordStrength,
                                  style: TextStyle(
                                    color: _strengthColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password must contain:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                _buildRequirement('At least 6 characters',
                                    _passwordController.text.length >= 6),
                                _buildRequirement(
                                    'At least 1 uppercase letter',
                                    _passwordController.text
                                        .contains(RegExp(r'[A-Z]'))),
                                _buildRequirement(
                                    'At least 1 special character',
                                    _passwordController.text.contains(
                                        RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          LoginInput(
                            type: "confirm password",
                            controller: _confirmPasswordController,
                            hasError: _hasConfirmPasswordError,
                            hasText: _hasConfirmPasswordText,
                          ),
                          if (_hasConfirmPasswordError &&
                              _hasConfirmPasswordText) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Passwords do not match',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 32.h),
                          LoginButton(
                            text: "Continue",
                            onTap: _handleNext,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: AppColors.fontPurple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: AppColors.fontPurple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 16.w,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

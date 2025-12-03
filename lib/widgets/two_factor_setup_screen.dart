// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/models/two_factor_auth.dart';
import 'package:app_tact/utils/input_utils.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _currentStep = 0;
  String _firstPassword = '';
  String? _existingPassword;
  bool _isCheckingExisting = true;

  @override
  void initState() {
    super.initState();
    _checkExistingPassword();
  }

  Future<void> _checkExistingPassword() async {
    final password = await TwoFactorAuth.check2fa();

    setState(() {
      if (password != null) {
        _existingPassword = password;
        _currentStep = 0;
      } else {
        _currentStep = 1;
      }
      _isCheckingExisting = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleNext() {
    String enteredCode = InputUtils.getEnteredCode(_controllers);

    if (enteredCode.length != 6) {
      MessageUtils.showErrorMessage(context, 'Please enter all 6 digits');
      return;
    }

    if (_currentStep == 0) {
      if (TwoFactorAuth.verify2fa(enteredCode, _existingPassword)) {
        setState(() {
          _currentStep = 1;
          _existingPassword = null;
        });
        InputUtils.clearFields(_controllers, _focusNodes);
      } else {
        MessageUtils.showErrorMessage(
            context, 'Incorrect password. Please try again.');
        InputUtils.clearFields(_controllers, _focusNodes);
      }
    } else if (_currentStep == 1) {
      setState(() {
        _firstPassword = enteredCode;
        _currentStep = 2;
      });
      InputUtils.clearFields(_controllers, _focusNodes);
    } else {
      if (!TwoFactorAuth.matchPasswords(enteredCode, _firstPassword)) {
        MessageUtils.showErrorMessage(
            context, 'Passwords do not match. Please try again.');
        setState(() {
          _currentStep = 1;
          _firstPassword = '';
        });
        InputUtils.clearFields(_controllers, _focusNodes);
        return;
      }
      _saveToFirebase(enteredCode);
    }
  }

  Future<void> _saveToFirebase(String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TwoFactorAuth.save2fa(password);

      if (mounted) {
        MessageUtils.showSuccessMessage(
            context, 'Two-factor authentication password set successfully');
        Navigator.pop(context, password);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        MessageUtils.showErrorMessage(
            context, 'Failed to save password: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingExisting) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.gradientDarkBlue, AppColors.gradientPurple],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    String title;
    String description;
    String stepText;
    String buttonText;

    if (_currentStep == 0) {
      title = 'Verify Current Password';
      description = 'Enter your current 6-digit 2FA password to make changes.';
      stepText = 'Verification';
      buttonText = 'Verify';
    } else if (_currentStep == 1) {
      title = 'Set Two-Factor Authentication Password';
      description =
          'Create a 6-digit password for two-factor authentication. You will be asked for this password when logging in.';
      stepText = '1 of 2';
      buttonText = 'Next';
    } else {
      title = 'Confirm Your Password';
      description = 'Please re-enter your 6-digit password to confirm.';
      stepText = '2 of 2';
      buttonText = 'Set Password';
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientDarkBlue, AppColors.gradientPurple],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: Text(
            'Setup 2FA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(
                      Icons.security,
                      size: 80.sp,
                      color: AppColors.accentPurple,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    _currentStep == 0
                        ? 'Enter current password:'
                        : (_currentStep == 1
                            ? 'Enter your 6-digit password:'
                            : 'Confirm your password:'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50.w,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.accentPurple,
                                width: 2,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15.h),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) => InputUtils.handleDigitChange(
                              index, value, _focusNodes),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 30.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      stepText,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFB93CFF),
                          Color(0xFF4F46E5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              buttonText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:app_tact/widgets/password_change/create_new_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterVerificationCodeScreen extends StatefulWidget {
  final String currentPassword;
  final String generatedCode;

  const EnterVerificationCodeScreen({
    super.key,
    required this.currentPassword,
    required this.generatedCode,
  });

  @override
  State<EnterVerificationCodeScreen> createState() =>
      _EnterVerificationCodeScreenState();
}

class _EnterVerificationCodeScreenState
    extends State<EnterVerificationCodeScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verifyCode() {
    if (_codeController.text.trim().isEmpty) {
      MessageUtils.showErrorMessage(
          context, 'Please enter the verification code');
      return;
    }

    if (_codeController.text.trim() != widget.generatedCode) {
      MessageUtils.showErrorMessage(context, 'Verification code is incorrect');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewPasswordScreen(
          currentPassword: widget.currentPassword,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Enter Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(),
                SizedBox(height: 40.h),
                Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Please enter the 6-digit code sent to your email',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 30.h),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    letterSpacing: 8,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    counterText: '',
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
                    onPressed: _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Verify Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepCircle(1, false, true),
        _buildConnector(true),
        _buildStepCircle(2, false, true),
        _buildConnector(true),
        _buildStepCircle(3, true, false),
        _buildConnector(false),
        _buildStepCircle(4, false, false),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive, bool isCompleted) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted
            ? AppColors.accentPurple
            : Colors.white.withOpacity(0.3),
        border: Border.all(
          color: isActive || isCompleted
              ? AppColors.accentPurple
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, color: Colors.white, size: 20.sp)
            : Text(
                '$step',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color:
            isActive ? AppColors.accentPurple : Colors.white.withOpacity(0.3),
      ),
    );
  }
}

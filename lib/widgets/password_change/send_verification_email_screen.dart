// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:app_tact/colors.dart';
import 'package:app_tact/widgets/password_change/enter_verification_code_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SendVerificationEmailScreen extends StatefulWidget {
  final String currentPassword;

  const SendVerificationEmailScreen({
    super.key,
    required this.currentPassword,
  });

  @override
  State<SendVerificationEmailScreen> createState() =>
      _SendVerificationEmailScreenState();
}

class _SendVerificationEmailScreenState
    extends State<SendVerificationEmailScreen> {
  bool _isLoading = false;

  String _generateVerificationCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String code = _generateVerificationCode();

      // Show code in dialog (development mode)
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color.fromARGB(255, 41, 41, 59),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            title: Text(
              'Verification Code',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your verification code is:',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 10.h),
                Text(
                  code,
                  style: TextStyle(
                    color: AppColors.accentPurple,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '(Development mode)',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(color: AppColors.accentPurple),
                ),
              ),
            ],
          ),
        );

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EnterVerificationCodeScreen(
              currentPassword: widget.currentPassword,
              generatedCode: code,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

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
            'Email Verification',
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
                  'Email Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'We need to verify that you own this account. We\'ll send a verification code to your email.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 30.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppColors.accentPurple,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          user?.email ?? 'No email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
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
                    onPressed: _isLoading ? null : _sendVerificationEmail,
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
                            'Send Verification Code',
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
        _buildStepCircle(2, true, false),
        _buildConnector(false),
        _buildStepCircle(3, false, false),
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

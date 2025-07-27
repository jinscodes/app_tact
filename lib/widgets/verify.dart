// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/models/navigate.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final AuthService _authService = AuthService();
  bool _isCheckingVerification = false;
  bool _isResendingEmail = false;

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isCheckingVerification = true;
    });

    try {
      await _authService.reloadUser();

      if (_authService.isEmailVerified) {
        Navigate.toAndRemoveUntil(context, '/welcome');
      } else {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 2), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              height: 180.h,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Verify Your Email",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Email not verified yet. Please check your inbox and click the verification link, or resend the verification email.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isCheckingVerification = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResendingEmail = true;
    });

    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isResendingEmail = false;
      });
    }
  }

  @override
  void dispose() {
    if (!_authService.isEmailVerified) {
      Future.microtask(() async {
        try {
          await _authService.deleteCurrentUser();
          print('User account deleted');
        } catch (e) {
          print('Error deleting account: $e');
        }
      });
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Verify Email',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.baseBlack,
          ),
          onPressed: () {
            Navigate.toAndRemoveUntil(context, '/login');
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 32.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Check your inbox",
                  style: TextStyle(
                    color: AppColors.baseBlack,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "We've sent a verification email to your address. Please click the link in the email to verify your account.",
                style: TextStyle(
                  color: AppColors.baseBlack,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed:
                      _isCheckingVerification ? null : _checkEmailVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: _isCheckingVerification
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Check Email",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed:
                      _isResendingEmail ? null : _resendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    side: BorderSide(
                      color: AppColors.inputBoldGray,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: _isResendingEmail
                      ? CircularProgressIndicator(color: AppColors.buttonGray)
                      : Text(
                          "Resend Verification Email",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonGray,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

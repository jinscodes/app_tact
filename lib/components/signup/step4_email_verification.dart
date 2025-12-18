// ignore_for_file: deprecated_member_use, unused_field

import 'dart:async';

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/login/login_button.dart';
import 'package:app_tact/components/login/logo_and_title.dart';
import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Step4EmailVerification extends StatefulWidget {
  final String email;
  final Function() onVerificationComplete;
  final VoidCallback onBack;
  final VoidCallback onResendCode;
  final bool isLoading;

  const Step4EmailVerification({
    super.key,
    required this.email,
    required this.onVerificationComplete,
    required this.onBack,
    required this.onResendCode,
    this.isLoading = false,
  });

  @override
  State<Step4EmailVerification> createState() => _Step4EmailVerificationState();
}

class _Step4EmailVerificationState extends State<Step4EmailVerification> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final AuthService _authService = AuthService();
  bool _hasError = false;
  String _errorMessage = '';
  final bool _isResendEnabled = true;
  final int _resendCooldown = 0;
  StreamSubscription<User?>? _authStateSubscription;
  Timer? _verificationCheckTimer;
  bool _isCheckingVerification = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });

    // Send verification email when screen loads
    _sendInitialVerificationEmail();

    _startVerificationDetection();

    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        setState(() {
          _hasError = false;
          _errorMessage = '';
        });
      });
    }
  }

  Future<void> _sendInitialVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
      print('✅ Verification email sent to ${widget.email}');
    } catch (e) {
      print('⚠️ Error sending initial verification email: $e');
    }
  }

  void _handleVerification() async {
    try {
      await _authService.reloadUser();

      if (_authService.isEmailVerified) {
        widget.onVerificationComplete();
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Please check your email and click the verification link before proceeding.';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to verify email status. Please try again.';
      });
    }
  }

  void _handleResendCode() async {
    try {
      await _authService.sendEmailVerification();

      if (mounted) {
        MessageUtils.showSuccessMessage(
          context,
          'Verification email sent to ${widget.email}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Failed to resend verification email. Please try again.';
        });
      }
    }
  }

  void _startVerificationDetection() {
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        _checkEmailVerification();
      }
    });

    _verificationCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _checkEmailVerification();
      }
    });
  }

  void _checkEmailVerification() async {
    if (_isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
    });

    try {
      await _authService.reloadUser();

      if (_authService.isEmailVerified && mounted) {
        _stopVerificationDetection();

        MessageUtils.showSuccessMessage(
          context,
          'Email verified successfully!',
        );

        await Future.delayed(const Duration(milliseconds: 500));

        widget.onVerificationComplete();
      }
    } catch (e) {
      print('Background verification check failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  void _stopVerificationDetection() {
    _authStateSubscription?.cancel();
    _verificationCheckTimer?.cancel();
  }

  @override
  void dispose() {
    _stopVerificationDetection();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
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
                            title: "Check your email",
                            subtitle: "We sent a verification code",
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isCheckingVerification) ...[
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ] else ...[
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.blue,
                                    size: 16.w,
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Text(
                                  _isCheckingVerification
                                      ? 'Checking verification status...'
                                      : 'Automatically checking for verification',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          LoginButton(
                            text: "Verify Code",
                            isLoading: widget.isLoading,
                            onTap:
                                widget.isLoading ? null : _handleVerification,
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code? ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    _isResendEnabled ? _handleResendCode : null,
                                child: Text(
                                  _isResendEnabled
                                      ? 'Resend Code'
                                      : 'Resend in ${_resendCooldown}s',
                                  style: TextStyle(
                                    color: _isResendEnabled
                                        ? AppColors.fontPurple
                                        : Colors.grey,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          GestureDetector(
                            onTap: widget.isLoading ? null : widget.onBack,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.grey,
                                    size: 16.w,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Back to previous step',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
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
}

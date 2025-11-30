import 'package:app_tact/colors.dart';
import 'package:app_tact/components/divider_with_text.dart';
import 'package:app_tact/components/login_button.dart';
import 'package:app_tact/components/login_input.dart';
import 'package:app_tact/components/logo_and_title.dart';
import 'package:app_tact/components/signup_with_github.dart';
import 'package:app_tact/components/signup_with_google.dart';
import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Step1Email extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final Function(String name, String email) onNext;
  final VoidCallback onBack;

  const Step1Email({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step1Email> createState() => _Step1EmailState();
}

class _Step1EmailState extends State<Step1Email> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _hasNameError = false;
  bool _hasEmailError = false;
  bool _hasNameText = false;
  bool _hasEmailText = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _emailController.text = widget.initialEmail;
    _hasNameText = widget.initialName.isNotEmpty;
    _hasEmailText = widget.initialEmail.isNotEmpty;

    _nameController.addListener(() {
      setState(() {
        _hasNameText = _nameController.text.isNotEmpty;
      });
    });

    _emailController.addListener(() {
      setState(() {
        _hasEmailText = _emailController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      bool success = await _authService.signUpWithGoogle();
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showErrorMessage(
            context, 'Google authentication failed: $e');
      }
    }
  }

  void _handleNext() {
    setState(() {
      _hasNameError = false;
      _hasEmailError = false;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _hasNameError = true;
      });
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _hasEmailError = true;
      });
      return;
    }

    if (_authService
        .isGoogleEmail(_emailController.text.trim().toLowerCase())) {
      _handleGoogleSignUp();
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() {
        _hasEmailError = true;
      });
      return;
    }

    widget.onNext(_nameController.text.trim(), _emailController.text.trim());
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
                            title: "What's your info?",
                            subtitle: "Tell us about yourself",
                          ),
                          SizedBox(height: 32.h),
                          LoginInput(
                            type: "full name",
                            controller: _nameController,
                            hasError: _hasNameError,
                            hasText: _hasNameText,
                          ),
                          SizedBox(height: 16.h),
                          LoginInput(
                            type: "email",
                            controller: _emailController,
                            hasError: _hasEmailError,
                            hasText: _hasEmailText,
                          ),
                          SizedBox(height: 32.h),
                          LoginButton(
                            text: "Continue",
                            onTap: _handleNext,
                          ),
                          DividerWithText(),
                          Row(
                            children: [
                              SignupWithGoogle(),
                              SignupWithGithub(),
                            ],
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
                                  color: Colors.grey.withOpacity(0.3),
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
}

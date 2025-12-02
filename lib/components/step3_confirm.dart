// ignore_for_file: avoid_print, deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/login_button.dart';
import 'package:app_tact/components/logo_and_title.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Step3Confirm extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final Function(String name, String email, String password) onSignup;
  final VoidCallback onBack;
  final VoidCallback onNavigateToLogin;
  final bool isLoading;

  const Step3Confirm({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.onSignup,
    required this.onBack,
    required this.onNavigateToLogin,
    this.isLoading = false,
  });

  @override
  State<Step3Confirm> createState() => _Step3ConfirmState();
}

class _Step3ConfirmState extends State<Step3Confirm> {
  bool _agreeToTerms = false;

  Future<void> _handleSignup() async {
    if (!_agreeToTerms) {
      MessageUtils.showErrorMessage(
          context, 'Please agree to Terms & Conditions');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      await userCredential.user?.updateDisplayName(widget.name);

      if (userCredential.user != null) {
        try {
          final profileData = {
            'email': widget.email,
            'memberSince': FieldValue.serverTimestamp(),
            'userId': userCredential.user!.uid,
            'name': widget.name,
            'createdAt': FieldValue.serverTimestamp(),
            'signupType': 'email',
          };

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .collection('profile')
              .doc('info')
              .set(profileData);
        } catch (profileError, stackTrace) {
          print('❌ Error creating profile: $profileError');
          print('❌ Stack trace: $stackTrace');
        }

        try {
          await userCredential.user!.sendEmailVerification();

          if (mounted) {
            MessageUtils.showSuccessMessage(
                context, 'Verification email sent to ${widget.email}!');
          }
        } catch (emailError) {
          if (mounted) {
            MessageUtils.showErrorMessage(context,
                'Account created but failed to send verification email. Please check your email or try resending.');
          }
        }
      } else {
        throw Exception('User creation failed - user is null');
      }

      widget.onSignup(widget.name, widget.email, widget.password);
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');

      String errorMessage = 'Failed to create account';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          try {
            User? existingUser = FirebaseAuth.instance.currentUser;
            if (existingUser != null && !existingUser.emailVerified) {
              await existingUser.sendEmailVerification();
              errorMessage = 'Account exists. New verification email sent!';
            }
          } catch (resendError) {
            print('Failed to resend verification: $resendError');
          }
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during signup';
      }

      if (mounted) {
        MessageUtils.showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      print('❌ Unexpected error: $e');

      if (mounted) {
        MessageUtils.showErrorMessage(
            context, 'An unexpected error occurred: ${e.toString()}');
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
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
                            title: "Almost there!",
                            subtitle: "Confirm your details",
                          ),
                          SizedBox(height: 32.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _buildDetailRow('Name', widget.name),
                                SizedBox(height: 8.h),
                                _buildDetailRow('Email', widget.email),
                                SizedBox(height: 8.h),
                                _buildDetailRow(
                                    'Password', '•' * widget.password.length),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: widget.isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _agreeToTerms = value ?? false;
                                        });
                                      },
                                activeColor: AppColors.fontPurple,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: widget.isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _agreeToTerms = !_agreeToTerms;
                                          });
                                        },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 12.h),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14.sp,
                                        ),
                                        children: [
                                          const TextSpan(
                                              text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms & Conditions',
                                            style: TextStyle(
                                              color: AppColors.fontPurple,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: AppColors.fontPurple,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),
                          LoginButton(
                            text: "Create Account",
                            isLoading: widget.isLoading,
                            onTap: widget.isLoading ? null : _handleSignup,
                          ),
                          SizedBox(height: 18.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.isLoading
                                    ? null
                                    : widget.onNavigateToLogin,
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: AppColors.fontPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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

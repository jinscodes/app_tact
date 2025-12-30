// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/components/loading_spinner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginWithGoogle extends StatefulWidget {
  const LoginWithGoogle({super.key});

  @override
  State<LoginWithGoogle> createState() => _LoginWithGoogleState();
}

class _LoginWithGoogleState extends State<LoginWithGoogle> {
  final AuthService _authService = AuthService();
  bool _isGoogleLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      print('🔵 Starting Google login...');
      UserCredential? result = await _authService.signInWithGoogle();

      if (result != null && result.user != null) {
        print('🔵 Google login successful! User: ${result.user!.email}');

        // Check if profile exists, if not create one
        try {
          print('🔵 Checking if profile exists...');
          final profileDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(result.user!.uid)
              .collection('profile')
              .doc('info')
              .get();

          print('🔵 Profile exists: ${profileDoc.exists}');

          if (!profileDoc.exists) {
            print('🔵 Creating profile for Google login user...');
            final profileData = {
              'email': result.user!.email,
              'memberSince': FieldValue.serverTimestamp(),
              'userId': result.user!.uid,
              'name': result.user!.displayName ?? 'User',
              'createdAt': FieldValue.serverTimestamp(),
              'signupType': 'google',
            };

            await FirebaseFirestore.instance
                .collection('users')
                .doc(result.user!.uid)
                .collection('profile')
                .doc('info')
                .set(profileData);
            print('✅ Profile created successfully for Google login!');
          } else {
            print('ℹ️ Profile already exists');
          }
        } catch (profileError) {
          print('❌ Error creating profile: $profileError');
        }
        // Navigate only on successful sign-in
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        // User cancelled Google sign-in; do nothing.
        print('ℹ️ Google sign-in cancelled by user');
        if (mounted) {
          setState(() {
            _isGoogleLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Google authentication failed: $e');
      final msg = e.toString().toLowerCase();
      final isCancelled = msg.contains('popup_closed_by_user') ||
          msg.contains('canceled') ||
          msg.contains('cancelled') ||
          msg.contains('sign_in_canceled') ||
          msg.contains('aborted');
      if (mounted) {
        if (!isCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google authentication failed. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 48.h,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          color: Color(0xFF393A4D),
        ),
        child: InkWell(
          onTap: _isGoogleLoading ? null : () => _signInWithGoogle(),
          borderRadius: BorderRadius.circular(10.r),
          child: _isGoogleLoading
              ? const Center(child: LoginLoadingSpinner())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.g_mobiledata,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Google',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:app_sticker_note/services/auth_service.dart';
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
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google authentication failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
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
              ? Center(
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
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

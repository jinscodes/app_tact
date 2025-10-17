// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:app_sticker_note/models/navigate.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginWithGoogle extends StatefulWidget {
  const LoginWithGoogle({super.key});

  @override
  State<LoginWithGoogle> createState() => _LoginWithGoogleState();
}

class _LoginWithGoogleState extends State<LoginWithGoogle> {
  bool _isGoogleLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle() async {
    print('Starting Google Sign-In process...');
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      print('Cleared previous Google Sign-In session');

      print('Calling AuthService.signInWithGoogle()...');
      UserCredential? result = await _authService.signInWithGoogle();

      if (result != null && result.user != null) {
        print('Google Sign-In successful! User: ${result.user!.email}');
        if (result.additionalUserInfo?.isNewUser == true) {
          print('New Google user created: ${result.user!.email}');
        } else {
          print('Existing Google user signed in: ${result.user!.email}');
        }
        Navigate.toAndRemoveUntil(context, '/home');
      } else {
        print('Google sign-in was cancelled by user');
      }
    } on FirebaseAuthException catch (e) {
      print(
          'Firebase Auth error during Google sign-in: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: ${e.message}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on Exception catch (e) {
      print('General error during Google sign-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in with Google. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
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

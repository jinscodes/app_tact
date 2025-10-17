// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:app_sticker_note/models/navigate.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginWithGitHub extends StatefulWidget {
  const LoginWithGitHub({super.key});

  @override
  State<LoginWithGitHub> createState() => _LoginWithGitHubState();
}

class _LoginWithGitHubState extends State<LoginWithGitHub> {
  bool _isGitHubLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _signInWithGitHub() async {
    print('Starting GitHub Sign-In process...');
    setState(() {
      _isGitHubLoading = true;
    });

    try {
      print('Calling AuthService.signInWithGitHub()...');
      UserCredential? result = await _authService.signInWithGitHub();

      if (result != null && result.user != null) {
        print('GitHub Sign-In successful! User: ${result.user!.email}');
        if (result.additionalUserInfo?.isNewUser == true) {
          print('New GitHub user created: ${result.user!.email}');
        } else {
          print('Existing GitHub user signed in: ${result.user!.email}');
        }
        Navigate.toAndRemoveUntil(context, '/home');
      } else {
        print('GitHub sign-in was cancelled by user');
      }
    } on FirebaseAuthException catch (e) {
      print(
          'Firebase Auth error during GitHub sign-in: ${e.code} - ${e.message}');
      if (mounted) {
        String errorMessage;
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
                'An account already exists with this email using a different sign-in method.';
            break;
          case 'invalid-credential':
            errorMessage = 'GitHub authentication failed. Please try again.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'GitHub sign-in is not enabled.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          default:
            errorMessage =
                e.message ?? 'Failed to sign in with GitHub. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on Exception catch (e) {
      print('General error during GitHub sign-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in with GitHub. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGitHubLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 48.h,
        margin: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
          color: Color(0xFF393A4D),
        ),
        child: InkWell(
          onTap: _isGitHubLoading ? null : () => _signInWithGitHub(),
          borderRadius: BorderRadius.circular(10.r),
          child: _isGitHubLoading
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
                      Icons.code,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'GitHub',
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

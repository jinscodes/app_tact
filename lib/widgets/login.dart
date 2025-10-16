// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use, unused_field

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/models/navigate.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _hasEmailText = false;
  bool _hasPasswordText = false;
  bool _isLoading = false;
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  bool _isGoogleLoading = false;
  bool _isGitHubLoading = false; // Add GitHub loading state
  String _emailErrorMessage = '';
  String _passwordErrorMessage = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    setState(() {
      _hasEmailError = false;
      _hasPasswordError = false;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _hasEmailError = _emailController.text.isEmpty;
        _hasPasswordError = _passwordController.text.isEmpty;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? result = await _authService.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);

      if (result != null &&
          result.user != null &&
          !result.user!.emailVerified) {
        await _authService.signOut();
        return;
      }

      Navigate.toAndRemoveUntil(context, '/home');
    } on FirebaseAuthException catch (e) {
      print(e.message);
      setState(() {
        _hasEmailError = true;
        _hasPasswordError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: LayoutBuilder(
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
                        Image.asset(
                          './assets/tact_logo.png',
                          width: 50.w,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Login to your account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.fontGray,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
                          child: Text(
                            'Email',
                            style: TextStyle(
                              color: AppColors.fontGray,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF3E3C47), Color(0xFF292A34)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              width: 2,
                              color: _hasEmailError
                                  ? Colors.red.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Colors.white,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 50.w,
                                  vertical: 14.h,
                                ),
                                hintText: 'Enter your email',
                                hintStyle:
                                    TextStyle(color: AppColors.placeholderGray),
                                border: InputBorder.none,
                              ),
                              onChanged: (v) {
                                setState(() {
                                  _hasEmailText = v.isNotEmpty;
                                  if (v.isNotEmpty) {
                                    _hasEmailError = false;
                                    _emailErrorMessage = '';
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
                          child: Text(
                            'Password',
                            style: TextStyle(
                              color: AppColors.fontGray,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF3E3C47), Color(0xFF292A34)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              width: 2,
                              color: _hasEmailError
                                  ? Colors.red.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              cursorColor: Colors.white,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.sp),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 50.w,
                                  vertical: 14.h,
                                ),
                                hintText: 'Enter your password',
                                hintStyle:
                                    TextStyle(color: AppColors.placeholderGray),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.fontGray,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              onChanged: (v) {
                                setState(() {
                                  _hasPasswordText = v.isNotEmpty;
                                  if (v.isNotEmpty) {
                                    _hasPasswordError = false;
                                    _passwordErrorMessage = '';
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigate.toAndRemoveUntil(
                                  context, '/forgot-password');
                            },
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: AppColors.fontPurple,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: _isLoading ? null : _signIn,
                          child: Container(
                            height: 56.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFFB93CFF), Color(0xFF4F46E5)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFB93CFF).withOpacity(0.28),
                                  blurRadius: 18.r,
                                  offset: Offset(0, 8.h),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.fontGray.withOpacity(0.8),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  color: AppColors.fontGray,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.fontGray.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48.h,
                                margin: EdgeInsets.only(right: 8.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.12)),
                                  color: Color(0xFF393A4D),
                                ),
                                child: InkWell(
                                  onTap: _isGoogleLoading
                                      ? null
                                      : () => _signInWithGoogle(),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                            ),
                            Expanded(
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
                                  onTap: _isGitHubLoading
                                      ? null
                                      : () => _signInWithGitHub(),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: AppColors.fontGray,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigate.toAndRemoveUntil(context, '/signup'),
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: AppColors.fontPurple,
                                  fontWeight: FontWeight.bold,
                                ),
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
    );
  }
}

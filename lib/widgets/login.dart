// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/models/navigate.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _hasEmailText = false; // kept for potential future use
  bool _hasPasswordText = false; // kept for potential future use
  bool _isLoading = false;
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  String _emailErrorMessage = '';
  String _passwordErrorMessage = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    setState(() {
      _hasEmailError = false;
      _hasPasswordError = false;
      _emailErrorMessage = '';
      _passwordErrorMessage = '';
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) {
          _hasEmailError = true;
          _emailErrorMessage = 'Please enter your email';
        }
        if (password.isEmpty) {
          _hasPasswordError = true;
          _passwordErrorMessage = 'Please enter your password';
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? result =
          await _authService.signInWithEmailAndPassword(email, password);

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
        if (e.code == 'user-not-found') {
          _hasEmailError = true;
          _emailErrorMessage = 'No account found with this email';
        } else if (e.code == 'wrong-password') {
          _hasPasswordError = true;
          _passwordErrorMessage = 'Incorrect password';
        } else if (e.code == 'invalid-email') {
          _hasEmailError = true;
          _emailErrorMessage = 'Invalid email format';
        } else if (e.code == 'too-many-requests') {
          _hasEmailError = true;
          _hasPasswordError = true;
          _emailErrorMessage =
              'Too many failed attempts. Please try again later';
        } else {
          _hasEmailError = true;
          _hasPasswordError = true;
          _emailErrorMessage = 'Login failed. Please check your credentials';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                                  onTap: () {
                                    // Google sign-in
                                    _signIn();
                                  },
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Row(
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
                                  onTap: () {
                                    // GitHub sign-in placeholder
                                  },
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Row(
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

// ignore_for_file: use_build_context_synchronously, avoid_print

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
  bool _hasEmailText = false;
  bool _hasPasswordText = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  String _email = '';
  String _password = '';

  Future<void> _signIn() async {
    setState(() {
      _hasEmailError = false;
      _hasPasswordError = false;
    });

    if (_email.isEmpty || _password.isEmpty) {
      setState(() {
        _hasEmailError = _email.isEmpty;
        _hasPasswordError = _password.isEmpty;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? result =
          await _authService.signInWithEmailAndPassword(_email, _password);

      if (result != null &&
          result.user != null &&
          !result.user!.emailVerified) {
        await _authService.signOut();
        return;
      }

      Navigate.to(context, '/home');
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
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      UserCredential? result = await _authService.signInWithGoogle();

      if (result != null && result.user != null) {
        if (result.additionalUserInfo?.isNewUser == true) {
          print('New Google user created: ${result.user!.email}');
        } else {
          print('Existing Google user signed in: ${result.user!.email}');
        }
        Navigate.toAndRemoveUntil(context, '/home');
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60.h),
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        "N",
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Sign in to access your notes',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.fontGray,
                    ),
                  ),
                  SizedBox(height: 36.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _hasEmailText = value.isNotEmpty;
                            _email = value;
                            if (_hasEmailError && value.isNotEmpty) {
                              _hasEmailError = false;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your Email",
                          hintStyle: TextStyle(
                            color: AppColors.placeholderGray,
                            fontSize: 15.sp,
                          ),
                          filled: true,
                          fillColor: AppColors.inputGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: _hasEmailError
                                ? BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  )
                                : _hasEmailText
                                    ? BorderSide(
                                        color: AppColors.inputBoldGray,
                                        width: 2,
                                      )
                                    : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: _hasEmailError
                                  ? Colors.red
                                  : AppColors.inputBoldGray,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        obscureText: !_isPasswordVisible,
                        onChanged: (value) {
                          setState(() {
                            _hasPasswordText = value.isNotEmpty;
                            _password = value;
                            if (_hasPasswordError && value.isNotEmpty) {
                              _hasPasswordError = false;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: TextStyle(
                            color: AppColors.placeholderGray,
                            fontSize: 15.sp,
                          ),
                          filled: true,
                          fillColor: AppColors.inputGray,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.fontGray,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: _hasPasswordError
                                ? BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  )
                                : _hasPasswordText
                                    ? BorderSide(
                                        color: AppColors.inputBoldGray,
                                        width: 2,
                                      )
                                    : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: _hasPasswordError
                                  ? Colors.red
                                  : AppColors.inputBoldGray,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            print("Click Forgot Password");
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.forgotGray,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonGray,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Sign In",
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
                              _isGoogleLoading ? null : _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: AppColors.buttonGray,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: _isGoogleLoading
                              ? CircularProgressIndicator(
                                  color: AppColors.buttonGray)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.g_mobiledata_outlined,
                                      color: AppColors.buttonGray,
                                      size: 36.sp,
                                    ),
                                    Text(
                                      "Sign in with Google",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.buttonGray,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 50.h),
                    ],
                  ),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.fontGray,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () => Navigate.to(context, '/signup'),
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
                          child: Text(
                            "Create Account",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

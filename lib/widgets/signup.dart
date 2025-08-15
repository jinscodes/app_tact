// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/models/navigate.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  bool _hasNameText = false;
  bool _hasEmailText = false;
  bool _hasPasswordText = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _hasNameError = false;
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false;

  Future<void> _signUp() async {
    setState(() {
      _hasNameError = false;
      _hasEmailError = false;
      _hasPasswordError = false;
    });

    if (_name.isEmpty || _email.isEmpty || _password.isEmpty) {
      setState(() {
        _hasNameError = _name.isEmpty;
        _hasEmailError = _email.isEmpty;
        _hasPasswordError = _password.isEmpty;
      });
      return;
    }

    if (_password.length < 6) {
      setState(() {
        _hasPasswordError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? result =
          await _authService.registerWithEmailAndPassword(_email, _password);

      if (result != null) {
        await result.user?.updateDisplayName(_name);

        await _authService.sendEmailVerification();

        Navigate.to(context, '/verify');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-email') {
          _hasEmailError = true;
        } else if (e.code == 'weak-password') {
          _hasPasswordError = true;
        } else if (e.code == 'email-already-in-use') {
          _hasEmailError = true;
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      UserCredential? result = await _authService.signInWithGoogle();

      if (result != null && result.user != null) {
        if (result.additionalUserInfo?.isNewUser == true) {
          print('New Google user created: ${result.user!.email}');
          Navigate.toAndRemoveUntil(context, '/home');
        } else {
          print('Existing Google user signed in: ${result.user!.email}');
          Navigate.toAndRemoveUntil(context, '/home');
        }
      }
    } catch (e) {
      print('Google Sign-Up error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up with Google. Please try again.'),
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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Signup',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.baseBlack,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                        _hasNameText = value.isNotEmpty;

                        if (_hasNameError && value.isNotEmpty) {
                          _hasNameError = false;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      hintStyle: TextStyle(
                        color: AppColors.placeholderGray,
                        fontSize: 15.sp,
                      ),
                      labelText: "Full Name",
                      filled: true,
                      fillColor: AppColors.inputGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: _hasNameError
                            ? BorderSide(
                                color: Colors.red,
                                width: 2,
                              )
                            : _hasNameText
                                ? BorderSide(
                                    color: AppColors.inputBoldGray,
                                    width: 2,
                                  )
                                : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: _hasNameError
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
                  SizedBox(height: 20.h),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                        _hasEmailText = value.isNotEmpty;

                        if (_hasEmailError && value.isNotEmpty) {
                          _hasEmailError = false;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(
                        color: AppColors.placeholderGray,
                        fontSize: 15.sp,
                      ),
                      labelText: "Email",
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
                  SizedBox(height: 20.h),
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
                      hintText: "password",
                      hintStyle: TextStyle(
                        color: AppColors.placeholderGray,
                        fontSize: 15.sp,
                      ),
                      labelText: "Password",
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
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
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
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isGoogleLoading ? null : _signUpWithGoogle,
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
                                  "Sign up with Google",
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
                  SizedBox(height: 18.h),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: AppColors.fontGray,
                        fontSize: 12.sp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

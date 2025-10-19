// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use, unused_field

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/components/divider_with_text.dart';
import 'package:app_sticker_note/components/login_button.dart';
import 'package:app_sticker_note/components/login_input.dart';
import 'package:app_sticker_note/components/login_with_github.dart';
import 'package:app_sticker_note/components/login_with_google.dart';
import 'package:app_sticker_note/components/logo_and_title.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:app_sticker_note/widgets/signup.dart';
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
  final bool _isPasswordVisible = false;
  bool _hasEmailText = false;
  bool _hasPasswordText = false;
  bool _isLoading = false;
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    setState(() {
      _hasEmailError = false;
      _hasPasswordError = false;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      print(_emailController.text);
      print(_passwordController.text);
      print(_hasEmailError);
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

      Navigator.pushNamed(context, '/home');
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

  void _navigateToSignup() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                          title: 'Welcome Back',
                          subtitle: 'Login to your account',
                        ),
                        LoginInput(
                          type: "email",
                          hasError: _hasEmailError,
                          hasText: _hasEmailText,
                          controller: _emailController,
                          onChanged: (v) {
                            setState(() {
                              _hasEmailText = v.isNotEmpty;
                              if (v.isNotEmpty) {
                                _hasEmailError = false;
                              }
                            });
                          },
                        ),
                        SizedBox(height: 16.h),
                        LoginInput(
                          type: 'password',
                          hasError: _hasPasswordError,
                          hasText: _hasPasswordText,
                          controller: _passwordController,
                          onChanged: (v) {
                            setState(() {
                              _hasPasswordText = v.isNotEmpty;
                              if (v.isNotEmpty) {
                                _hasPasswordError = false;
                              }
                            });
                          },
                        ),
                        SizedBox(height: 8.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
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
                        LoginButton(
                          text: 'Login',
                          isLoading: _isLoading,
                          onTap: _signIn,
                        ),
                        DividerWithText(),
                        Row(
                          children: [
                            LoginWithGoogle(),
                            LoginWithGitHub(),
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
                              onTap: () => _navigateToSignup(),
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
              ));
            },
          ),
        ),
      ),
    );
  }
}

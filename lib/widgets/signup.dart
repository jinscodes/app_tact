// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/components/divider_with_text.dart';
import 'package:app_sticker_note/components/login_button.dart';
import 'package:app_sticker_note/components/login_input.dart';
import 'package:app_sticker_note/components/logo_and_title.dart';
import 'package:app_sticker_note/components/signup_with_github.dart';
import 'package:app_sticker_note/components/signup_with_google.dart';
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
  final bool _hasNameText = false;
  final bool _hasEmailText = false;
  final bool _hasPasswordText = false;
  bool _isLoading = false;
  bool _hasNameError = false;
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  final String _name = '';
  final String _email = '';
  final String _password = '';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constrains) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constrains.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LogoAndTitle(
                        title: "Create Account",
                        subtitle: "Sign up to et started",
                      ),
                      LoginInput(
                        type: "name",
                        hasError: _hasNameError,
                        hasText: _hasNameText,
                      ),
                      SizedBox(height: 12.h),
                      LoginInput(
                        type: "email",
                        hasError: _hasEmailError,
                        hasText: _hasEmailText,
                      ),
                      SizedBox(height: 12.h),
                      LoginInput(
                        type: "password",
                        hasError: _hasPasswordError,
                        hasText: _hasPasswordText,
                      ),
                      SizedBox(height: 18.h),
                      LoginButton(
                        text: "Sign Up",
                        isLoading: _isLoading,
                        onTap: _signUp,
                      ),
                      DividerWithText(),
                      Row(
                        children: [
                          SignupWithGoogle(),
                          SignupWithGithub(),
                        ],
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
                            onTap: () => Navigate.to(context, '/login'),
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}

// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:app_sticker_note/components/step1_email.dart';
import 'package:app_sticker_note/components/step2_password.dart';
import 'package:app_sticker_note/components/step3_confirm.dart';
import 'package:app_sticker_note/components/step4_email_verification.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:app_sticker_note/widgets/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();

  String _name = '';
  String _email = '';
  String _password = '';

  int _currentStep = 1;
  bool _isLoading = false;

  void _handleStep1Complete(String name, String email) {
    setState(() {
      _name = name;
      _email = email;
      _currentStep = 2;
    });
  }

  void _handleStep2Complete(String password) {
    setState(() {
      _password = password;
      _currentStep = 3;
    });
  }

  Future<void> _handleStep3Complete(
      String name, String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      setState(() {
        _currentStep = 4;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification code: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailVerificationComplete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.currentUser?.updateDisplayName(_name);

      await _authService.signOut();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Email verified successfully! Please log in to continue.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred during signup';

        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          case 'email-already-in-use':
            errorMessage = 'Email is already in use';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendVerificationCode() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleStepBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 1:
        return Step1Email(
          initialName: _name,
          initialEmail: _email,
          onNext: _handleStep1Complete,
          onBack: _handleStepBack,
        );
      case 2:
        return Step2Password(
          initialPassword: _password,
          onNext: _handleStep2Complete,
          onBack: _handleStepBack,
        );
      case 3:
        return Step3Confirm(
          name: _name,
          email: _email,
          password: _password,
          onSignup: _handleStep3Complete,
          onBack: _handleStepBack,
          onNavigateToLogin: _navigateToLogin,
          isLoading: _isLoading,
        );
      case 4:
        return Step4EmailVerification(
          email: _email,
          onVerificationComplete: _handleEmailVerificationComplete,
          onBack: _handleStepBack,
          onResendCode: _handleResendVerificationCode,
          isLoading: _isLoading,
        );
      default:
        return Step1Email(
          initialName: _name,
          initialEmail: _email,
          onNext: _handleStep1Complete,
          onBack: _handleStepBack,
        );
    }
  }
}

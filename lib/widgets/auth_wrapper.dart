import 'package:app_tact/components/signup/step4_email_verification.dart';
import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/widgets/home.dart';
import 'package:app_tact/widgets/login.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        String initialRoute = authService.getInitialRoute();

        switch (initialRoute) {
          case '/home':
            return const HomeScreen();
          case '/verify':
            return _buildVerificationScreen(authService);
          default:
            return const LoginScreen();
        }
      },
    );
  }

  Widget _buildVerificationScreen(AuthService authService) {
    final user = authService.currentUser;
    if (user == null) {
      return const LoginScreen();
    }

    return Step4EmailVerification(
      email: user.email ?? '',
      onVerificationComplete: () {},
      onBack: () async {
        await authService.signOut();
      },
      onResendCode: () async {
        try {
          await authService.sendEmailVerification();
        } catch (e) {
          print('Failed to resend verification: $e');
        }
      },
    );
  }
}

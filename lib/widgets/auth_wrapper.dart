import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/services/theme_service.dart';
import 'package:app_tact/widgets/email_verification_screen.dart';
import 'package:app_tact/widgets/home.dart';
import 'package:app_tact/widgets/login.dart';
import 'package:app_tact/widgets/theme_picker_screen.dart';
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

        final route = authService.getInitialRoute();

        if (route == '/home') {
          if (!ThemeService.hasPicked) return const ThemePickerScreen();
          return const HomeScreen();
        }
        if (route == '/verify') return const EmailVerificationScreen();
        return const LoginScreen();
      },
    );
  }
}

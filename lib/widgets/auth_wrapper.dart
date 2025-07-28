import 'package:app_sticker_note/services/auth_service.dart';
import 'package:app_sticker_note/widgets/home.dart';
import 'package:app_sticker_note/widgets/login.dart';
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
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

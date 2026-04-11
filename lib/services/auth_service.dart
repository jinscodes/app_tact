// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn {
    User? user = _auth.currentUser;
    if (user == null) return false;

    return user.emailVerified ||
        user.providerData.any((provider) =>
            provider.providerId == 'google.com' ||
            provider.providerId == 'github.com');
  }

  String getInitialRoute() {
    User? user = _auth.currentUser;

    if (user == null) {
      return '/login';
    }

    bool isVerified = user.emailVerified ||
        user.providerData.any((provider) =>
            provider.providerId == 'google.com' ||
            provider.providerId == 'github.com');

    if (isVerified) {
      return '/home';
    } else {
      return '/verify';
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign-in was canceled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGitHub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();

      githubProvider.addScope('user:email');
      githubProvider.addScope('read:user');

      if (kIsWeb) {
        return await _auth.signInWithPopup(githubProvider);
      } else {
        return await _auth.signInWithProvider(githubProvider);
      }
    } on FirebaseAuthException catch (e) {
      print('GitHub sign-in error: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw FirebaseAuthException(
            code: e.code,
            message:
                'An account already exists with the same email address but different sign-in credentials.',
          );
        case 'invalid-credential':
          throw FirebaseAuthException(
            code: e.code,
            message: 'The credential received is malformed or has expired.',
          );
        case 'operation-not-allowed':
          throw FirebaseAuthException(
            code: e.code,
            message: 'GitHub sign-in is not enabled. Please contact support.',
          );
        case 'user-disabled':
          throw FirebaseAuthException(
            code: e.code,
            message: 'The user account has been disabled.',
          );
        case 'user-not-found':
          throw FirebaseAuthException(
            code: e.code,
            message: 'GitHub account not found.',
          );
        case 'web-storage-unsupported':
          throw FirebaseAuthException(
            code: e.code,
            message: 'Web storage is not supported or disabled.',
          );
        default:
          rethrow;
      }
    } catch (e) {
      print('Error signing in with GitHub: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      return await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<bool> isGoogleSignInAvailable() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      print('Error checking Google Sign-In availability: $e');
      return false;
    }
  }

  /// Returns the list of sign-in provider IDs already registered for [email].
  /// Possible values: 'password', 'google.com', 'apple.com', 'github.com'.
  /// Returns an empty list if the email is not registered at all.
  // ignore: deprecated_member_use
  Future<List<String>> fetchProvidersForEmail(String email) async {
    try {
      // ignore: deprecated_member_use
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      print('auth_service: providers for $email → $methods');
      return methods;
    } on FirebaseAuthException catch (e) {
      print('auth_service: fetchProvidersForEmail error: ${e.code}');
      return [];
    } catch (e) {
      print('auth_service: fetchProvidersForEmail unexpected error: $e');
      return [];
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('auth_service: sendEmailVerification — no current user');
        return;
      }
      if (user.emailVerified) {
        print('auth_service: sendEmailVerification skipped — already verified');
        return;
      }

      // ActionCodeSettings improves deliverability:
      //   • continueUrl  → the "Continue" button destination after verification
      //   • handleCodeInApp: false → link opens in browser (simpler & more reliable
      //     than deep linking; no extra Universal Links / App Links setup needed)
      //   • bundle / package IDs → Firebase can attach app-open hints in the email
      final settings = ActionCodeSettings(
        url: 'https://apptact-a4f0c.firebaseapp.com',
        handleCodeInApp: false,
        iOSBundleId: 'com.jay.app_tact',
        androidPackageName: 'com.jay.app_tact',
        androidInstallApp: false,
      );

      await user.sendEmailVerification(settings);
      print('auth_service: ✅ Verification email sent to ${user.email}');
    } on FirebaseAuthException catch (e) {
      print(
          'auth_service: ❌ Verification email error: ${e.code} — ${e.message}');
      rethrow;
    }
  }

  bool get isEmailVerified {
    User? user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Reloads the Firebase user from the server and returns the fresh
  /// [emailVerified] value. Use this for the verification-check button
  /// and auto-poll so stale cached state is never used.
  Future<bool> reloadAndCheckVerification() async {
    try {
      await _auth.currentUser?.reload();
      final fresh = _auth.currentUser;
      final verified = fresh?.emailVerified ?? false;
      print(
          'auth_service: reloadAndCheckVerification → verified=$verified (${fresh?.email})');
      return verified;
    } catch (e) {
      print('auth_service: reloadAndCheckVerification error: $e');
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Reload user error: $e');
    }
  }

  bool isGoogleEmail(String email) {
    String processedEmail = email.trim().toLowerCase();
    bool result = processedEmail.contains('gmail');
    return result;
  }

  Future<UserCredential?> signUpWithGoogle() async {
    try {
      // Don't sign out first - just proceed with sign-in
      UserCredential? result = await signInWithGoogle();
      return result;
    } catch (e) {
      print('Error during Google sign-up: $e');
      rethrow;
    }
  }
}

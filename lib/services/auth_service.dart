// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
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

  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.message}');
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
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('email verification sent to ${user.email}');
      }
    } on FirebaseAuthException catch (e) {
      print('Email verification error: ${e.message}');
      rethrow;
    }
  }

  bool get isEmailVerified {
    User? user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Reload user error: $e');
    }
  }

  Future<void> deleteCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        print('User account deleted: ${user.email}');
      }
    } on FirebaseAuthException catch (e) {
      print('Delete user error: ${e.message}');
      rethrow;
    }
  }

  bool shouldDeleteUnverifiedUser(
      {Duration timeLimit = const Duration(hours: 24)}) {
    User? user = _auth.currentUser;
    if (user == null) return false;

    if (user.emailVerified) return false;

    DateTime? creationTime = user.metadata.creationTime;
    if (creationTime != null) {
      return DateTime.now().difference(creationTime) > timeLimit;
    }

    return false;
  }
}

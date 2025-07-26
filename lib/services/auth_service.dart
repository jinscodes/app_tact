// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
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

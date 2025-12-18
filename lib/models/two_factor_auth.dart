import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoFactorAuth {
  static Future<String?> check2fa() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('2FAPassword')
            .get();

        if (doc.exists && doc.data()?['password'] != null) {
          return doc.data()!['password'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> save2fa(String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('2FAPassword');

      final doc = await docRef.get();
      String? lastPassword;
      bool? existingBiometric;
      bool? existing2FA;

      if (doc.exists) {
        if (doc.data()?['password'] != null) {
          lastPassword = doc.data()!['password'];
        }
        if (doc.data()?['biometricEnabled'] != null) {
          existingBiometric = doc.data()!['biometricEnabled'];
        }
        if (doc.data()?['twoFactorEnabled'] != null) {
          existing2FA = doc.data()!['twoFactorEnabled'];
        }
      }

      await docRef.set({
        'password': password,
        'lastPassword': lastPassword,
        'changedDate': FieldValue.serverTimestamp(),
        'biometricEnabled': existingBiometric ?? false,
        'twoFactorEnabled': existing2FA ?? false,
      });
    }
  }

  static Future<void> updateBiometricSetting(bool enabled) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('2FAPassword');

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'biometricEnabled': enabled,
        });
      } else {
        // Create document if it doesn't exist
        await docRef.set({
          'biometricEnabled': enabled,
          'twoFactorEnabled': false,
        });
      }
    }
  }

  static Future<void> updateTwoFactorSetting(bool enabled) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('2FAPassword');

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'twoFactorEnabled': enabled,
        });
      } else {
        // Create document if it doesn't exist
        await docRef.set({
          'biometricEnabled': false,
          'twoFactorEnabled': enabled,
        });
      }
    }
  }

  static Future<bool> getBiometricSetting() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('2FAPassword')
            .get();

        if (doc.exists && doc.data()?['biometricEnabled'] != null) {
          return doc.data()!['biometricEnabled'] as bool;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> getTwoFactorSetting() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('2FAPassword')
            .get();

        if (doc.exists && doc.data()?['twoFactorEnabled'] != null) {
          return doc.data()!['twoFactorEnabled'] as bool;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool verify2fa(String enteredPassword, String? existingPassword) {
    return enteredPassword == existingPassword;
  }

  static bool matchPasswords(String password1, String password2) {
    return password1 == password2;
  }
}

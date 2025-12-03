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

      // Get existing password before updating
      final doc = await docRef.get();
      String? lastPassword;
      if (doc.exists && doc.data()?['password'] != null) {
        lastPassword = doc.data()!['password'];
      }

      // Save new password, lastPassword, and changedDate
      await docRef.set({
        'password': password,
        'lastPassword': lastPassword,
        'changedDate': FieldValue.serverTimestamp(),
      });
    }
  }

  static bool verify2fa(String enteredPassword, String? existingPassword) {
    return enteredPassword == existingPassword;
  }

  static bool matchPasswords(String password1, String password2) {
    return password1 == password2;
  }
}

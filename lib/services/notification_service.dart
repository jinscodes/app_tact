import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<bool> hasRequestedNotificationPermission() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return true;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notification')
          .doc('updates')
          .get();

      if (!doc.exists) return false;

      final data = doc.data();
      return data?['firstReq'] != null;
    } catch (e) {
      print('Error checking notification permission: $e');
      return true;
    }
  }

  Future<void> setNotificationPreferences({
    required bool enabled,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final batch = FirebaseFirestore.instance.batch();

      // Save settings
      final settingsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notification')
          .doc('settings');

      batch.set(settingsRef, {
        'pushNotifications': enabled,
        'emailNotifications': enabled,
        'linkReminders': enabled,
        'weeklyDigest': enabled,
        'newFeatures': enabled,
        'promotions': enabled,
      });

      // Save updates with firstReq
      final updatesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notification')
          .doc('updates');

      batch.set(updatesRef, {
        'firstReq': enabled,
        'firstReqDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      print('Error setting notification preferences: $e');
      rethrow;
    }
  }
}

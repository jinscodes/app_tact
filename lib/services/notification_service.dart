import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted || status.isLimited || status.isProvisional;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> setNotificationPreferences({
    required bool enabled,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final batch = FirebaseFirestore.instance.batch();

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
      debugPrint('Error setting notification preferences: $e');
      rethrow;
    }
  }

  void persistNotificationPreferenceInBackground({required bool enabled}) {
    unawaited(setNotificationPreferences(enabled: enabled));
  }
}

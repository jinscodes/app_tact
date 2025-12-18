import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletionService {
  static Future<void> performAccountDeletion(User user) async {
    String uid = user.uid;

    final profileDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('info')
        .get();

    Map<String, dynamic> profileData =
        profileDoc.exists && profileDoc.data() != null
            ? profileDoc.data()!
            : {};

    await FirebaseFirestore.instance
        .collection('deletedUsers')
        .doc(uid)
        .collection('profile')
        .doc('info')
        .set({
      'deletedAt': FieldValue.serverTimestamp(),
      ...profileData,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('status')
        .set({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    await user.delete();
  }
}

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _categoriesCollection =>
      _firestore.collection('users').doc(_userId).collection('categories');

  Future<void> initializeDefaultCategories() async {
    if (_userId == null) return;

    print('🔥 Current User ID: $_userId');
    print('🔥 Initializing categories for user: $_userId');

    try {
      final snapshot = await _categoriesCollection.get();

      if (snapshot.docs.isEmpty) {
        print('🔥 No categories found, creating defaults...');
        final defaultCategories = [
          {
            'name': 'Work',
            'isDefault': true,
            'createdAt': FieldValue.serverTimestamp()
          },
          {
            'name': 'Personal',
            'isDefault': true,
            'createdAt': FieldValue.serverTimestamp()
          },
        ];

        WriteBatch batch = _firestore.batch();
        for (var category in defaultCategories) {
          DocumentReference docRef = _categoriesCollection.doc();
          batch.set(docRef, category);
        }
        await batch.commit();
        print('🔥 Default categories created successfully!');
      } else {
        print('🔥 Found ${snapshot.docs.length} existing categories');
      }
    } catch (e) {
      print('Error initializing default categories: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getCategories() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _categoriesCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'isDefault': data['isDefault'] ?? false,
          'createdAt': data['createdAt'],
        };
      }).toList();
    });
  }

  Future<void> addCategory(String name) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _categoriesCollection.add({
        'name': name.trim(),
        'isDefault': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(String categoryId, String newName) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _categoriesCollection.doc(categoryId).update({
        'name': newName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  Future<bool> categoryExists(String name) async {
    if (_userId == null) return false;

    try {
      final snapshot = await _categoriesCollection
          .where('name', isEqualTo: name.trim())
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking category existence: $e');
      return false;
    }
  }
}

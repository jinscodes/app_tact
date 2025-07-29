// ignore_for_file: avoid_print

import 'package:app_sticker_note/models/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _categoriesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  Stream<List<Category>> getCategoriesStream() {
    try {
      return _categoriesCollection
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Category.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('Error getting categories stream: $e');
      return Stream.value([]);
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _categoriesCollection
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Category.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<String?> addCategory(String name) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final existingCategories = await getCategories();
      if (existingCategories
          .any((cat) => cat.name.toLowerCase() == name.toLowerCase())) {
        throw Exception('Category with this name already exists');
      }

      final docRef = _categoriesCollection.doc();
      final category = Category(
        id: docRef.id,
        name: name.trim(),
        userId: userId,
        createdAt: DateTime.now(),
        isDefault: false,
      );

      await docRef.set(category.toMap());
      print('Category added successfully: $name');
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(String categoryId, String newName) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final existingCategories = await getCategories();
      if (existingCategories.any((cat) =>
          cat.name.toLowerCase() == newName.toLowerCase() &&
          cat.id != categoryId)) {
        throw Exception('Category with this name already exists');
      }

      await _categoriesCollection.doc(categoryId).update({
        'name': newName.trim(),
      });
      print('Category updated successfully: $newName');
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final categoryDoc = await _categoriesCollection.doc(categoryId).get();
      if (!categoryDoc.exists) {
        throw Exception('Category not found');
      }

      final category = Category.fromFirestore(
          categoryDoc.id, categoryDoc.data() as Map<String, dynamic>);

      if (category.isDefault) {
        throw Exception('Default categories cannot be deleted');
      }

      await _categoriesCollection.doc(categoryId).delete();
      print('Category deleted successfully');
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  Future<void> initializeDefaultCategories() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final existingCategories = await getCategories();
      if (existingCategories.isNotEmpty) return;

      final defaultCategories = [
        'Personal',
        'Work',
        'Ideas',
        'Shopping',
        'To-Do',
      ];

      final batch = _firestore.batch();

      for (String categoryName in defaultCategories) {
        final docRef = _categoriesCollection.doc();
        final category = Category(
          id: docRef.id,
          name: categoryName,
          userId: userId,
          createdAt: DateTime.now(),
          isDefault: true,
        );
        batch.set(docRef, category.toMap());
      }

      await batch.commit();
      print('Default categories initialized');
    } catch (e) {
      print('Error initializing default categories: $e');
      rethrow;
    }
  }

  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (!doc.exists) return null;

      return Category.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting category by ID: $e');
      return null;
    }
  }

  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      final categories = await getCategories();
      return categories.any((cat) =>
          cat.name.toLowerCase() == name.toLowerCase() &&
          (excludeId == null || cat.id != excludeId));
    } catch (e) {
      print('Error checking category name: $e');
      return false;
    }
  }
}

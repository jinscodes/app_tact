// ignore_for_file: avoid_print

import 'package:app_tact/models/make_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LinksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  bool get isUserAuthenticated {
    return _auth.currentUser != null;
  }

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  CollectionReference _getCategoryCollection() {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  CollectionReference _getLinkItemsCollection(String categoryId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .collection('linkItems');
  }

  Future<String> createCategoryWithCollection(String categoryName) async {
    try {
      if (categoryName.trim().isEmpty) {
        throw Exception('Category name cannot be empty');
      }

      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final existingCategories = await getCategories();

      if (existingCategories
          .any((cat) => cat.name.toLowerCase() == categoryName.toLowerCase())) {
        throw Exception('Category with this name already exists');
      }

      final categoryRef = _getCategoryCollection().doc();

      final category = Category(
        id: categoryRef.id,
        name: categoryName.trim(),
        userId: userId,
        createdAt: DateTime.now(),
        linkCount: 0,
      );

      print('Creating batch operations...');
      final batch = _firestore.batch();

      batch.set(categoryRef, category.toMap());

      final linkItemsInitRef =
          _getLinkItemsCollection(categoryRef.id).doc('_init');
      batch.set(linkItemsInitRef, {
        'categoryId': categoryRef.id,
        'createdAt': DateTime.now().toIso8601String(),
        'isPlaceholder': true,
      });

      await batch.commit();

      return categoryRef.id;
    } catch (e) {
      print('Error in createCategoryWithCollection: $e');
      rethrow;
    }
  }

  Future<String> addLinkToCategory(
      String categoryId, String title, String url, String description) async {
    try {
      if (title.trim().isEmpty || url.trim().isEmpty) {
        throw Exception('Title and URL are required');
      }

      final linkRef = _getLinkItemsCollection(categoryId).doc();
      final linkItem = LinkItem(
        id: linkRef.id,
        title: title.trim(),
        url: url.trim(),
        description: description.trim(),
        categoryId: categoryId,
        userId: userId,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();

      batch.set(linkRef, linkItem.toMap());

      final categoryRef = _getCategoryCollection().doc(categoryId);
      batch.update(categoryRef, {
        'linkCount': FieldValue.increment(1),
      });

      await batch.commit();

      return linkRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _getCategoryCollection()
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Category.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Category>> getCategoriesStream() {
    try {
      return _getCategoryCollection()
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Category.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<List<LinkItem>> getLinksByCategory(String categoryId) async {
    try {
      final snapshot = await _getLinkItemsCollection(categoryId)
          .where('isPlaceholder', isNotEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => LinkItem.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<LinkItem>> getLinksByCategoryStream(String categoryId) {
    try {
      return _getLinkItemsCollection(categoryId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isPlaceholder'] != true;
            })
            .map((doc) => LinkItem.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('Error in getLinksByCategoryStream: $e');
      return Stream.value([]);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final batch = _firestore.batch();

      final linkItems = await _getLinkItemsCollection(categoryId).get();
      for (final doc in linkItems.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_getCategoryCollection().doc(categoryId));

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLinkItem(String categoryId, String linkId) async {
    try {
      final batch = _firestore.batch();

      batch.delete(_getLinkItemsCollection(categoryId).doc(linkId));

      batch.update(_getCategoryCollection().doc(categoryId), {
        'linkCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLinkItem(
    String categoryId,
    String linkId, {
    String? title,
    String? url,
    String? description,
    bool? isFavorite,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title.trim();
      if (url != null) updates['url'] = url.trim();
      if (description != null) updates['description'] = description.trim();
      if (isFavorite != null) updates['isFavorite'] = isFavorite;

      await _getLinkItemsCollection(categoryId).doc(linkId).update(updates);
    } catch (e) {
      rethrow;
    }
  }
}

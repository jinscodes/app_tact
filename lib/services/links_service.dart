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

  CollectionReference get _linksCollection {
    return _firestore.collection('users').doc(userId).collection('links');
  }

  CollectionReference _getCategoryCollection() {
    return _linksCollection.doc('categories').collection('items');
  }

  CollectionReference _getLinkItemsCollection(String categoryId) {
    return _linksCollection
        .doc('categories')
        .collection('items')
        .doc(categoryId)
        .collection('linkItems');
  }

  /// Creates the Firebase collection structure and adds a category
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

      final linksDocRef = _linksCollection.doc('metadata');
      batch.set(
          linksDocRef,
          {
            'userId': userId,
            'createdAt': DateTime.now().toIso8601String(),
            'totalCategories': 1,
          },
          SetOptions(merge: true));

      final categoriesDocRef = _linksCollection.doc('categories');
      batch.set(categoriesDocRef, {
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
      });

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

  /// Adds a link item to a specific category
  Future<String> addLinkToCategory(
      String categoryId, String title, String url, String description) async {
    try {
      if (title.trim().isEmpty || url.trim().isEmpty) {
        throw Exception('Title and URL are required');
      }

      // Create link item
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

      // Update category link count and add link item in a batch
      final batch = _firestore.batch();

      // Add the link item
      batch.set(linkRef, linkItem.toMap());

      // Update category link count
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

  /// Gets all categories for the current user
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

  /// Gets categories as a stream for real-time updates
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

  /// Gets all link items for a specific category
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

  /// Gets link items as a stream for real-time updates
  Stream<List<LinkItem>> getLinksByCategoryStream(String categoryId) {
    try {
      return _getLinkItemsCollection(categoryId)
          .where('isPlaceholder', isNotEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => LinkItem.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Deletes a category and all its link items
  Future<void> deleteCategory(String categoryId) async {
    try {
      final batch = _firestore.batch();

      // Delete all link items in the category
      final linkItems = await _getLinkItemsCollection(categoryId).get();
      for (final doc in linkItems.docs) {
        batch.delete(doc.reference);
      }

      // Delete the category
      batch.delete(_getCategoryCollection().doc(categoryId));

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a specific link item
  Future<void> deleteLinkItem(String categoryId, String linkId) async {
    try {
      final batch = _firestore.batch();

      // Delete the link item
      batch.delete(_getLinkItemsCollection(categoryId).doc(linkId));

      // Update category link count
      batch.update(_getCategoryCollection().doc(categoryId), {
        'linkCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates a link item
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

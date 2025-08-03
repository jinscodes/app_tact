// ignore_for_file: avoid_print

import 'package:app_sticker_note/models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _notesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('notes');
  }

  Stream<List<Note>> getNotesStream() {
    try {
      return _notesCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Note.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      print('Error getting notes stream: $e');
      rethrow;
    }
  }

  Stream<List<Note>> getNotesByCategoryStream(String categoryId) {
    try {
      print('Getting notes for category: $categoryId');
      return _notesCollection
          .where('categoryId', isEqualTo: categoryId)
          .snapshots()
          .map((snapshot) {
        print(
            'Category stream snapshot received: ${snapshot.docs.length} notes');
        final notes = snapshot.docs.map((doc) {
          return Note.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        // Sort in memory instead of using orderBy to avoid composite index requirement
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return notes;
      });
    } catch (e) {
      print('Error getting notes by category stream: $e');
      rethrow;
    }
  }

  Stream<List<Note>> getFavoriteNotesStream() {
    try {
      return _notesCollection
          .where('isStarred', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Note.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      print('Error getting favorite notes stream: $e');
      rethrow;
    }
  }

  Future<void> addNote({
    required String title,
    required String description,
    required String categoryId,
    bool isStarred = false,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (title.trim().isEmpty) {
        throw Exception('Title cannot be empty');
      }
      if (description.trim().isEmpty) {
        throw Exception('Description cannot be empty');
      }
      if (categoryId.trim().isEmpty) {
        throw Exception('Category must be selected');
      }

      final docRef = _notesCollection.doc();
      final now = DateTime.now();

      final note = Note(
        id: docRef.id,
        title: title.trim(),
        description: description.trim(),
        categoryId: categoryId,
        userId: userId,
        createdAt: now,
        isStarred: isStarred,
      );

      await docRef.set(note.toMap());
      print('Note added successfully: ${note.id}');
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  Future<void> updateNote({
    required String noteId,
    String? title,
    String? description,
    String? categoryId,
    bool? isStarred,
  }) async {
    try {
      if (noteId.trim().isEmpty) {
        throw Exception('Note ID cannot be empty');
      }

      final updateData = <String, dynamic>{};

      if (title != null) {
        if (title.trim().isEmpty) {
          throw Exception('Title cannot be empty');
        }
        updateData['title'] = title.trim();
      }

      if (description != null) {
        if (description.trim().isEmpty) {
          throw Exception('Description cannot be empty');
        }
        updateData['description'] = description.trim();
      }

      if (categoryId != null) {
        if (categoryId.trim().isEmpty) {
          throw Exception('Category must be selected');
        }
        updateData['categoryId'] = categoryId;
      }

      if (isStarred != null) {
        updateData['isStarred'] = isStarred;
      }

      if (updateData.isEmpty) {
        throw Exception('No data to update');
      }

      await _notesCollection.doc(noteId).update(updateData);
      print('Note updated successfully: $noteId');
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String noteId) async {
    try {
      if (noteId.trim().isEmpty) {
        throw Exception('Note ID cannot be empty');
      }

      final doc = await _notesCollection.doc(noteId).get();
      if (!doc.exists) {
        throw Exception('Note not found');
      }

      final note =
          Note.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      await updateNote(noteId: noteId, isStarred: !note.isStarred);
      print('Note favorite toggled: $noteId');
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      if (noteId.trim().isEmpty) {
        throw Exception('Note ID cannot be empty');
      }

      await _notesCollection.doc(noteId).delete();
      print('Note deleted successfully: $noteId');
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  Future<Note?> getNoteById(String noteId) async {
    try {
      if (noteId.trim().isEmpty) {
        throw Exception('Note ID cannot be empty');
      }

      final doc = await _notesCollection.doc(noteId).get();
      if (!doc.exists) {
        return null;
      }

      return Note.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting note by ID: $e');
      rethrow;
    }
  }

  Future<int> getNotesCount() async {
    try {
      final snapshot = await _notesCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting notes count: $e');
      rethrow;
    }
  }

  Future<int> getNotesCategoryCount(String categoryId) async {
    try {
      final snapshot = await _notesCollection
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting notes count by category: $e');
      rethrow;
    }
  }
}

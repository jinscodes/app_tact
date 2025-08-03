// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/components/menu_drawer.dart';
import 'package:app_sticker_note/components/note_card.dart';
import 'package:app_sticker_note/components/show_create_menu.dart';
import 'package:app_sticker_note/models/category.dart';
import 'package:app_sticker_note/models/navigate.dart';
import 'package:app_sticker_note/models/note.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:app_sticker_note/services/category_service.dart';
import 'package:app_sticker_note/services/note_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final CategoryService _categoryService = CategoryService();
  final NoteService _noteService = NoteService();
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    try {
      await _categoryService.initializeDefaultCategories();
    } catch (e) {
      print('Error initializing categories: $e');
    }
  }

  void _onCategorySelected(Category? category) {
    setState(() {
      _selectedCategory = category;
    });

    String message = category == null
        ? 'Showing all notes'
        : 'Showing notes in "${category.name}"';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      _authService.signOut();
      Navigate.toAndRemoveUntil(context, '/login');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  void _createNote() {
    Navigate.to(context, '/create-note');
  }

  Future<void> _toggleFavorite(Note note) async {
    try {
      await _noteService.toggleFavorite(note.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to update favorite: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedCategory == null ? 'All Notes' : _selectedCategory!.name,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.menu_rounded,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.filter_alt_outlined,
            ),
          ),
        ],
      ),
      drawer: MenuDrawer(
        onSignOut: _signOut,
        onCategorySelected: _onCategorySelected,
      ),
      body: StreamBuilder<List<Note>>(
        stream: _selectedCategory == null
            ? _noteService.getNotesStream()
            : _noteService.getNotesByCategoryStream(_selectedCategory!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: CircularProgressIndicator(
                      color: AppColors.baseBlack,
                      strokeWidth: 3.0,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading notes...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            print('StreamBuilder error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading notes',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    child: Text('Show All Notes'),
                  ),
                ],
              ),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _selectedCategory == null
                        ? 'No notes yet'
                        : 'No notes in ${_selectedCategory!.name}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap the + button to create your first note',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onToggleFavorite: () => _toggleFavorite(note),
                  onTap: () {
                    print('Note tapped: ${note.title}');
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: AppColors.baseBlack,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => ShowCreateMenu.show(
            context: context,
            onCreateNote: _createNote,
            onCreateCategory: () => Navigate.to(context, '/manage-category'),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.add,
            size: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

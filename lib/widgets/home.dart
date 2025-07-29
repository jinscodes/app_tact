// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/components/menu_drawer.dart';
import 'package:app_sticker_note/components/show_create_menu.dart';
import 'package:app_sticker_note/models/category.dart';
import 'package:app_sticker_note/models/navigate.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:app_sticker_note/services/category_service.dart';
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
    // Here you can filter notes by category
    // For now, just show a snackbar
    String message = category == null
        ? 'Showing all notes'
        : 'Showing notes for: ${category.name}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Create Note feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _createCategory() {
    Navigate.to(context, '/manage-category');
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Sticky Notes!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'You are successfully logged in.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
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
            onCreateCategory: _createCategory,
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

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/models/category.dart';
import 'package:app_sticker_note/models/note.dart';
import 'package:app_sticker_note/services/category_service.dart';
import 'package:app_sticker_note/services/note_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;

  const EditNoteScreen({
    super.key,
    required this.note,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  final NoteService _noteService = NoteService();
  final GlobalKey _dropdownKey = GlobalKey();

  String? _selectedCategoryId;
  bool _isStarred = false;
  bool _isLoading = false;
  List<Category> _categories = [];
  bool _categoriesLoaded = false;
  bool _canSaveCache = false;

  @override
  void initState() {
    super.initState();
    _initializeWithNote();
    _titleController.addListener(_updateSaveButtonState);
    _descriptionController.addListener(_updateSaveButtonState);
    _loadCategories();
  }

  void _initializeWithNote() {
    _titleController.text = widget.note.title;
    _descriptionController.text = widget.note.description;
    _selectedCategoryId = widget.note.categoryId;
    _isStarred = widget.note.isStarred;
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _categoriesLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesLoaded = true;
        });
      }
    }
  }

  void _updateSaveButtonState() {
    final canSaveNow = _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _selectedCategoryId != null;
    if (canSaveNow != _canSaveCache) {
      setState(() {
        _canSaveCache = canSaveNow;
      });
    }
  }

  Future<void> _updateNote() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedCategoryId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _noteService.updateNote(
        noteId: widget.note.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        isStarred: _isStarred,
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update note: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildCategoryDropdown() {
    if (!_categoriesLoaded) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Color(0xFFF3F3F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Loading categories...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      key: _dropdownKey,
      value: _selectedCategoryId,
      decoration: InputDecoration(
        hintText: 'Select a category',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: Color(0xFFF3F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
      ),
      items: _categories.map((Category category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(
            category.name,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.baseBlack,
            ),
          ),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedCategoryId = value;
        });
        _updateSaveButtonState();
      },
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateSaveButtonState);
    _descriptionController.removeListener(_updateSaveButtonState);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Note',
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16.w),
              child: TextButton(
                onPressed: _canSaveCache && !_isLoading ? _updateNote : null,
                style: TextButton.styleFrom(
                  backgroundColor: _canSaveCache && !_isLoading
                      ? AppColors.baseBlack
                      : Color(0xFF8E8E95),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter title',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.sp,
                          ),
                          filled: true,
                          fillColor: Color(0xFFF3F3F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildCategoryDropdown(),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.normal,
                              color: AppColors.baseBlack,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isStarred = !_isStarred;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  _isStarred ? Icons.star : Icons.star_border,
                                  color: _isStarred
                                      ? Colors.amber
                                      : Colors.grey[400],
                                  size: 20.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  _isStarred ? 'Starred' : 'Add to favorites',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _isStarred
                                        ? Colors.amber
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Enter description',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.sp,
                          ),
                          filled: true,
                          fillColor: Color(0xFFF3F3F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

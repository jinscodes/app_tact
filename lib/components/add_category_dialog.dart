// ignore_for_file: deprecated_member_use

import 'package:app_tact/services/links_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(String categoryName) onCategoryAdded;

  const AddCategoryDialog({
    super.key,
    required this.onCategoryAdded,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();

  static Future<void> show(
    BuildContext context, {
    required Function(String categoryName) onCategoryAdded,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AddCategoryDialog(
          onCategoryAdded: onCategoryAdded,
        );
      },
    );
  }
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _categoryController = TextEditingController();
  final LinksService _linksService = LinksService();
  bool _isLoading = false;
  bool _isInputEmpty = true;

  @override
  void initState() {
    super.initState();
    _categoryController.addListener(_updateInputState);
  }

  void _updateInputState() {
    setState(() {
      _isInputEmpty = _categoryController.text.trim().isEmpty;
    });
  }

  @override
  void dispose() {
    _categoryController.removeListener(_updateInputState);
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360.w,
        height: 250.h,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 41, 41, 59),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Color(0xFF585967),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  "Add New Category",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                "Category Name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _categoryController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFF353442),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        minimumSize: Size(0, 42.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        gradient: _isInputEmpty || _isLoading
                            ? LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.grey.withOpacity(0.5),
                                  Colors.grey.withOpacity(0.5),
                                ],
                              )
                            : LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFFB93CFF),
                                  Color(0xFF4F46E5),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.r),
                          onTap: _isInputEmpty || _isLoading
                              ? null
                              : () async {
                                  await _handleAddCategory();
                                },
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Add",
                                    style: TextStyle(
                                      color: _isInputEmpty
                                          ? Colors.grey[600]
                                          : Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddCategory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categoryName = _categoryController.text.trim();

      // Check if user is authenticated
      if (!_linksService.isUserAuthenticated) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      print(
          'Creating category: $categoryName for user: ${_linksService.currentUserId}');

      // Create category in Firebase using LinksService
      await _linksService.createCategoryWithCollection(categoryName);

      print('Category created successfully');

      // Call the callback to notify parent widget
      widget.onCategoryAdded(categoryName);

      // Close the dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error creating category: $e');
      // Show error message
      if (mounted) {
        MessageUtils.showErrorMessage(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageCategoryScreen extends StatefulWidget {
  const ManageCategoryScreen({super.key});

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _categoryController.addListener(() {
      setState(() {});
    });

    _categoryService.initializeDefaultCategories();
  }

  void _addCategory() async {
    if (_categoryController.text.trim().isNotEmpty) {
      try {
        final exists = await _categoryService
            .categoryExists(_categoryController.text.trim());
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Category "${_categoryController.text}" already exists!'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        await _categoryService.addCategory(_categoryController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${_categoryController.text}" added!'),
            backgroundColor: Colors.green,
          ),
        );
        _categoryController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editCategory(Map<String, dynamic> category) async {
    if (category['isDefault']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Default categories cannot be edited'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    TextEditingController editController = TextEditingController(
      text: category['name'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              hintText: 'Enter category name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteCategory(category);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.trim().isNotEmpty) {
                  try {
                    await _categoryService.updateCategory(
                        category['id'], editController.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category updated!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating category: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(Map<String, dynamic> category) async {
    if (category['isDefault']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Default categories cannot be deleted'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content:
              Text('Are you sure you want to delete "${category['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _categoryService.deleteCategory(category['id']);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category deleted!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting category: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Manage Categories',
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
                        'Add New Category',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Category Name",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _categoryController,
                              decoration: InputDecoration(
                                hintText: 'Enter category name',
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
                              onSubmitted: (_) => _addCategory(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            decoration: BoxDecoration(
                              color: _categoryController.text.trim().isNotEmpty
                                  ? AppColors.baseBlack
                                  : Color(0xFF8E8E95),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: IconButton(
                              onPressed: _addCategory,
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                            ),
                          ),
                        ],
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
                        'Existing Categories',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Manage your categories. Default categories cannot be deleted.",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _categoryService.getCategories(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error loading categories: ${snapshot.error}',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          final categories = snapshot.data ?? [];

                          if (categories.isEmpty) {
                            return Center(
                              child: Text(
                                'No categories found',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: categories.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            category['name'],
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.baseBlack,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: category['isDefault']
                                                  ? Colors.grey[100]
                                                  : Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              category['isDefault']
                                                  ? 'Default'
                                                  : 'Custom',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: category['isDefault']
                                                    ? Colors.grey[700]
                                                    : Colors.green[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _editCategory(category),
                                      icon: Icon(
                                        Icons.edit,
                                        color: category['isDefault']
                                            ? Colors.grey[400]
                                            : AppColors.baseBlack,
                                        size: 20.sp,
                                      ),
                                      padding: EdgeInsets.all(8.w),
                                      constraints: BoxConstraints(
                                        minWidth: 36.w,
                                        minHeight: 36.h,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:app_sticker_note/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageCategoryScreen extends StatefulWidget {
  const ManageCategoryScreen({super.key});

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Work', 'isDefault': true},
    {'name': 'Personal', 'isDefault': true},
    {'name': 'Learning', 'isDefault': false},
    {'name': 'Travel', 'isDefault': false},
  ];

  @override
  void initState() {
    super.initState();
    _categoryController.addListener(() {
      setState(() {});
    });
  }

  void _addCategory() {
    if (_categoryController.text.trim().isNotEmpty) {
      setState(() {
        _categories.add({
          'name': _categoryController.text.trim(),
          'isDefault': false,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "${_categoryController.text}" added!'),
          backgroundColor: Colors.green,
        ),
      );
      _categoryController.clear();
    }
  }

  void _editCategory(int index) {
    if (_categories[index]['isDefault']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Default categories cannot be edited'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    TextEditingController editController = TextEditingController(
      text: _categories[index]['name'],
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
                setState(() {
                  _categories[index]['name'] = editController.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Category updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  setState(() {
                    _categories[index]['name'] = editController.text.trim();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
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

  void _deleteCategory(int index) {
    if (_categories[index]['isDefault']) {
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
          content: Text(
              'Are you sure you want to delete "${_categories[index]['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _categories.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Category deleted!'),
                    backgroundColor: Colors.red,
                  ),
                );
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
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
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
                                  onPressed: () => _editCategory(index),
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

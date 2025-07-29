import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/models/category.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:app_sticker_note/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuDrawer extends StatelessWidget {
  final VoidCallback onSignOut;
  final Function(Category?)? onCategorySelected;

  const MenuDrawer({
    super.key,
    required this.onSignOut,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final CategoryService categoryService = CategoryService();

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.baseBlack,
                  ),
                  child: Center(
                    child: Text(
                      authService.currentUser?.displayName
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          authService.currentUser?.email
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'U',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  authService.currentUser?.displayName ??
                      authService.currentUser?.email ??
                      'User',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (authService.currentUser?.email != null)
                  Text(
                    authService.currentUser!.email!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.note_alt_outlined),
            title: const Text('All Notes'),
            onTap: () {
              Navigator.pop(context);
              if (onCategorySelected != null) {
                onCategorySelected!(null); // null means all notes
              }
            },
          ),
          const Divider(),
          // Categories Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/manage-category');
                  },
                  child: Icon(
                    Icons.settings,
                    size: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Dynamic Categories List
          StreamBuilder<List<Category>>(
            stream: categoryService.getCategoriesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Text(
                    'Error loading categories',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                );
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Text(
                    'No categories yet',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                );
              }

              return Column(
                children: categories.map((category) {
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.label_outline,
                      size: 20.sp,
                      color: category.isDefault
                          ? Colors.blue[600]
                          : Colors.grey[600],
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    trailing: category.isDefault
                        ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (onCategorySelected != null) {
                        onCategorySelected!(category);
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onSignOut();
            },
          ),
        ],
      ),
    );
  }
}

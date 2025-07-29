import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuDrawer extends StatelessWidget {
  final VoidCallback onSignOut;

  const MenuDrawer({
    super.key,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

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
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Manage Categories'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/manage-category');
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

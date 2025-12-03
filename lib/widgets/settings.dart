import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pop(context);
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientDarkBlue2, AppColors.gradientPurple],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              SectionTitle('Account'),
              CustomSettingTile(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Manage your profile information',
                onTap: () {},
              ),
              CustomSettingTile(
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () {},
              ),
              SizedBox(height: 20.h),
              SectionTitle('App'),
              CustomSettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {},
              ),
              CustomSettingTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Customize app theme',
                onTap: () {},
              ),
              SizedBox(height: 20.h),
              SectionTitle('Support'),
              CustomSettingTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
                onTap: () {},
              ),
              CustomSettingTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
              SizedBox(height: 20.h),
              SectionTitle('Account Actions'),
              CustomSettingTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: () async {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Color(0xFF2E2939),
            selectedItemColor: Color(0xFF7B68EE),
            unselectedItemColor: Colors.grey[600],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.link),
                label: 'Links',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

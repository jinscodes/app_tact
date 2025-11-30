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
        // Links
        Navigator.pop(context);
        break;
      case 1:
        // Already on Settings
        break;
      case 2:
        // Profile
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
          colors: [Color.fromARGB(255, 23, 30, 63), Color(0xFF2E2939)],
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
              _buildSectionTitle('Account'),
              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Manage your profile information',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () {},
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle('App'),
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Customize app theme',
                onTap: () {},
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle('Support'),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle('Account Actions'),
              _buildSettingTile(
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF7B68EE),
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.2)
                : Color(0xFF7B68EE).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red[400] : Color(0xFF7B68EE),
            size: 24.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red[400] : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13.sp,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[600],
          size: 24.sp,
        ),
        onTap: onTap,
      ),
    );
  }
}

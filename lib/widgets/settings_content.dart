import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/widgets/about_screen.dart';
import 'package:app_tact/widgets/help_support_screen.dart';
import 'package:app_tact/widgets/privacy_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsContent extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const SettingsContent({super.key, this.onNavigateToProfile});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onTap: () {
                widget.onNavigateToProfile?.call();
              },
            ),
            CustomSettingTile(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacySecurityScreen(),
                  ),
                );
              },
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
            ),
            CustomSettingTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
            SectionTitle('Account'),
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
    );
  }
}

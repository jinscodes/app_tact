// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _linkReminders = true;
  bool _weeklyDigest = false;
  bool _newFeatures = true;
  bool _promotions = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notification')
            .doc('settings')
            .get();

        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            setState(() {
              _pushNotifications = data['pushNotifications'] ?? true;
              _emailNotifications = data['emailNotifications'] ?? false;
              _linkReminders = data['linkReminders'] ?? true;
              _weeklyDigest = data['weeklyDigest'] ?? false;
              _newFeatures = data['newFeatures'] ?? true;
              _promotions = data['promotions'] ?? false;
              _isLoading = false;
            });
          }
        } else {
          await _saveNotificationSettings();
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final batch = FirebaseFirestore.instance.batch();

        final settingsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notification')
            .doc('settings');

        batch.set(settingsRef, {
          'pushNotifications': _pushNotifications,
          'emailNotifications': _emailNotifications,
          'linkReminders': _linkReminders,
          'weeklyDigest': _weeklyDigest,
          'newFeatures': _newFeatures,
          'promotions': _promotions,
        });

        final updatesRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notification')
            .doc('updates');

        batch.set(
            updatesRef,
            {
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));

        await batch.commit();
      }
    } catch (e) {
      if (context.mounted) {
        MessageUtils.showErrorMessage(
          context,
          'Failed to save settings',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientDarkBlue, AppColors.gradientPurple],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentPurple,
                ),
              )
            : SafeArea(
                child: ListView(
                  padding: EdgeInsets.all(20.w),
                  children: [
                    SectionTitle('General'),
                    _buildSwitchTile(
                      icon: Icons.notifications_active,
                      title: 'Push Notifications',
                      subtitle: 'Receive push notifications',
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.email_outlined,
                      title: 'Email Notifications',
                      subtitle: 'Receive notifications via email',
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    SizedBox(height: 20.h),
                    SectionTitle('Activity'),
                    _buildSwitchTile(
                      icon: Icons.link,
                      title: 'Link Reminders',
                      subtitle: 'Get reminded about saved links',
                      value: _linkReminders,
                      onChanged: (value) {
                        setState(() {
                          _linkReminders = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.calendar_today,
                      title: 'Weekly Digest',
                      subtitle: 'Weekly summary of your activity',
                      value: _weeklyDigest,
                      onChanged: (value) {
                        setState(() {
                          _weeklyDigest = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    SizedBox(height: 20.h),
                    SectionTitle('Updates'),
                    _buildSwitchTile(
                      icon: Icons.new_releases_outlined,
                      title: 'New Features',
                      subtitle: 'Updates about new features',
                      value: _newFeatures,
                      onChanged: (value) {
                        setState(() {
                          _newFeatures = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.local_offer_outlined,
                      title: 'Promotions',
                      subtitle: 'Special offers and promotions',
                      value: _promotions,
                      onChanged: (value) {
                        setState(() {
                          _promotions = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
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
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        secondary: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.accentPurple,
            size: 24.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: 13.sp,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accentPurple,
      ),
    );
  }
}

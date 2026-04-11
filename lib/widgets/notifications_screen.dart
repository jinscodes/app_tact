// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/custom_switch_tile.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/l10n/app_localizations.dart';
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
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context).rowNotifications,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7C6BFF),
                  strokeWidth: 2,
                ),
              )
            : SafeArea(
                child: ListView(
                  padding: EdgeInsets.all(20.w),
                  children: [
                    SectionTitle(
                        AppLocalizations.of(context).notifSectionGeneral),
                    CustomSwitchTile(
                      icon: Icons.notifications_active,
                      title: AppLocalizations.of(context).notifPushTitle,
                      subtitle: AppLocalizations.of(context).notifPushSubtitle,
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    CustomSwitchTile(
                      icon: Icons.email_outlined,
                      title: AppLocalizations.of(context).notifEmailTitle,
                      subtitle: AppLocalizations.of(context).notifEmailSubtitle,
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    SizedBox(height: 20.h),
                    SectionTitle(
                        AppLocalizations.of(context).notifSectionActivity),
                    CustomSwitchTile(
                      icon: Icons.link,
                      title:
                          AppLocalizations.of(context).notifLinkRemindersTitle,
                      subtitle: AppLocalizations.of(context)
                          .notifLinkRemindersSubtitle,
                      value: _linkReminders,
                      onChanged: (value) {
                        setState(() {
                          _linkReminders = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    CustomSwitchTile(
                      icon: Icons.calendar_today,
                      title:
                          AppLocalizations.of(context).notifWeeklyDigestTitle,
                      subtitle: AppLocalizations.of(context)
                          .notifWeeklyDigestSubtitle,
                      value: _weeklyDigest,
                      onChanged: (value) {
                        setState(() {
                          _weeklyDigest = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    SizedBox(height: 20.h),
                    SectionTitle(
                        AppLocalizations.of(context).notifSectionUpdates),
                    CustomSwitchTile(
                      icon: Icons.new_releases_outlined,
                      title: AppLocalizations.of(context).notifNewFeaturesTitle,
                      subtitle:
                          AppLocalizations.of(context).notifNewFeaturesSubtitle,
                      value: _newFeatures,
                      onChanged: (value) {
                        setState(() {
                          _newFeatures = value;
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    CustomSwitchTile(
                      icon: Icons.local_offer_outlined,
                      title: AppLocalizations.of(context).notifPromotionsTitle,
                      subtitle:
                          AppLocalizations.of(context).notifPromotionsSubtitle,
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
}

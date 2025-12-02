// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:app_tact/widgets/password_change/verify_current_password_screen.dart';
import 'package:app_tact/widgets/privacy_policy_screen.dart';
import 'package:app_tact/widgets/terms_of_service_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      // Enabling biometric - authenticate first
      try {
        bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
        bool isDeviceSupported = await _localAuth.isDeviceSupported();

        if (!canCheckBiometrics || !isDeviceSupported) {
          if (mounted) {
            MessageUtils.showErrorMessage(
              context,
              'Biometric authentication is not available on this device',
            );
          }
          return;
        }

        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to enable biometric login',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated && mounted) {
          setState(() {
            _biometricEnabled = true;
          });
        }
      } catch (e) {
        if (mounted) {
          MessageUtils.showErrorMessage(
            context,
            'Failed to authenticate: ${e.toString()}',
          );
        }
      }
    } else {
      // Disabling biometric - authenticate to confirm
      try {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to disable biometric login',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated && mounted) {
          setState(() {
            _biometricEnabled = false;
          });
        }
      } catch (e) {
        if (mounted) {
          MessageUtils.showErrorMessage(
            context,
            'Failed to authenticate: ${e.toString()}',
          );
        }
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
            'Privacy & Security',
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
              SectionTitle('Authentication'),
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID',
                value: _biometricEnabled,
                onChanged: _handleBiometricToggle,
              ),
              _buildSwitchTile(
                icon: Icons.security,
                title: 'Two-Factor Authentication',
                subtitle: 'Add an extra layer of security',
                value: _twoFactorEnabled,
                onChanged: (value) {
                  setState(() {
                    _twoFactorEnabled = value;
                  });
                  MessageUtils.showSuccessMessage(
                    context,
                    value ? '2FA enabled' : '2FA disabled',
                  );
                },
              ),
              SizedBox(height: 20.h),
              SectionTitle('Password'),
              CustomSettingTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    bool hasPasswordProvider = user.providerData.any(
                      (info) => info.providerId == 'password',
                    );

                    if (!hasPasswordProvider) {
                      String provider = 'social login';
                      if (user.providerData.isNotEmpty) {
                        String providerId = user.providerData.first.providerId;
                        if (providerId == 'google.com') {
                          provider = 'Google';
                        } else if (providerId == 'github.com') {
                          provider = 'GitHub';
                        }
                      }

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Color.fromARGB(255, 41, 41, 59),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: AppColors.accentPurple),
                              SizedBox(width: 8.w),
                              Text(
                                'Password Not Available',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.sp),
                              ),
                            ],
                          ),
                          content: Text(
                            'You signed in with $provider. Password changes are not available for social login accounts.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFB93CFF),
                                    Color(0xFF4F46E5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Text(
                                  'OK',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerifyCurrentPasswordScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              SectionTitle('Privacy Policy'),
              CustomSettingTile(
                icon: Icons.policy_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              CustomSettingTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServiceScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              SectionTitle('Data & Privacy'),
              CustomSettingTile(
                icon: Icons.download_outlined,
                title: 'Download Your Data',
                subtitle: 'Export your personal information',
                onTap: () {
                  MessageUtils.showSuccessMessage(
                    context,
                    'Data export will be sent to your email',
                  );
                },
              ),
              CustomSettingTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () {
                  _showDeleteAccountDialog();
                },
                isDestructive: true,
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.gradientPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            SizedBox(width: 8.w),
            Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.delete();
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                    MessageUtils.showSuccessMessage(
                      context,
                      'Account deleted successfully',
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  MessageUtils.showErrorMessage(
                    context,
                    'Failed to delete account: ${e.toString()}',
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}

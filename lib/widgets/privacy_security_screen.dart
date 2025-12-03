// ignore_for_file: deprecated_member_use, avoid_print

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:app_tact/widgets/password_change/verify_current_password_screen.dart';
import 'package:app_tact/widgets/privacy_policy_screen.dart';
import 'package:app_tact/widgets/terms_of_service_screen.dart';
import 'package:app_tact/widgets/two_factor_setup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _handleTwoFactorToggle(bool value) async {
    if (value) {
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
          localizedReason: 'Authenticate to enable two-factor authentication',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated && mounted) {
          setState(() {
            _twoFactorEnabled = true;
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
      try {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to disable two-factor authentication',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated && mounted) {
          setState(() {
            _twoFactorEnabled = false;
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
                onChanged: _handleTwoFactorToggle,
              ),
              CustomSettingTile(
                icon: Icons.pin_outlined,
                title: 'Set Two-Factor Authentication',
                subtitle: 'Configure 2FA with verification code',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TwoFactorSetupScreen(),
                    ),
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
              Navigator.pop(context);

              try {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await _performAccountDeletion(user);
                }
              } on FirebaseAuthException catch (e) {
                print('FirebaseAuthException: ${e.code}');
                if (e.code == 'requires-recent-login') {
                  if (context.mounted) {
                    _showReauthenticationDialog();
                  }
                } else {
                  if (context.mounted) {
                    MessageUtils.showErrorMessage(
                      context,
                      'Failed to delete account: ${e.message}',
                    );
                  }
                }
              } catch (e) {
                print('Error during deletion: $e');
                if (context.mounted) {
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

  Future<void> _performAccountDeletion(User user) async {
    String uid = user.uid;

    final profileDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('info')
        .get();

    Map<String, dynamic> profileData =
        profileDoc.exists && profileDoc.data() != null
            ? profileDoc.data()!
            : {};

    await FirebaseFirestore.instance
        .collection('deletedUsers')
        .doc(uid)
        .collection('profile')
        .doc('info')
        .set({
      'deletedAt': FieldValue.serverTimestamp(),
      ...profileData,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('status')
        .set({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    await user.delete();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  void _showReauthenticationDialog() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool hasPasswordProvider = user.providerData.any(
      (info) => info.providerId == 'password',
    );

    if (!hasPasswordProvider) {
      MessageUtils.showErrorMessage(
        context,
        'Please sign out and sign in again to delete your account',
      );
      return;
    }

    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.gradientPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Confirm Your Identity',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please enter your password to continue with account deletion.',
              style: TextStyle(color: AppColors.textLight),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: AppColors.textMedium),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: AppColors.accentPurple,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () async {
              String password = passwordController.text.trim();

              if (password.isEmpty) {
                MessageUtils.showErrorMessage(
                  context,
                  'Please enter your password',
                );
                return;
              }

              try {
                User? currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null && currentUser.email != null) {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: currentUser.email!,
                    password: password,
                  );

                  await currentUser.reauthenticateWithCredential(credential);
                  print('Reauthentication successful');

                  passwordController.dispose();

                  if (context.mounted) {
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentPurple,
                        ),
                      ),
                    );

                    await _performAccountDeletion(currentUser);
                  }
                }
              } on FirebaseAuthException catch (e) {
                print('Reauthentication error: ${e.code}');
                passwordController.dispose();
                if (context.mounted) {
                  Navigator.pop(context);
                  if (e.code == 'wrong-password') {
                    MessageUtils.showErrorMessage(
                      context,
                      'Incorrect password. Please try again.',
                    );
                  } else if (e.code == 'too-many-requests') {
                    MessageUtils.showErrorMessage(
                      context,
                      'Too many attempts. Please try again later.',
                    );
                  } else {
                    MessageUtils.showErrorMessage(
                      context,
                      'Authentication failed: ${e.message}',
                    );
                  }
                }
              } catch (e) {
                print('Error: $e');
                passwordController.dispose();
                if (context.mounted) {
                  Navigator.pop(context);
                  MessageUtils.showErrorMessage(
                    context,
                    'Failed to authenticate: ${e.toString()}',
                  );
                }
              }
            },
            child: Text(
              'Confirm',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}

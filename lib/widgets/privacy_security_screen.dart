// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/custom_switch_tile.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/components/dialogs/delete_account_dialog.dart';
import 'package:app_tact/components/dialogs/password_not_available_dialog.dart';
import 'package:app_tact/components/dialogs/reauthentication_dialog.dart';
import 'package:app_tact/components/dialogs/two_factor_required_dialog.dart';
import 'package:app_tact/models/two_factor_auth.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:app_tact/widgets/password_change/verify_current_password_screen.dart';
import 'package:app_tact/widgets/privacy_policy_screen.dart';
import 'package:app_tact/widgets/terms_of_service_screen.dart';
import 'package:app_tact/widgets/two_factor_setup_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final biometric = await TwoFactorAuth.getBiometricSetting();
    final twoFactor = await TwoFactorAuth.getTwoFactorSetting();

    if (mounted) {
      setState(() {
        _biometricEnabled = biometric;
        _twoFactorEnabled = twoFactor;
      });
    }
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      // Check if 2FA password exists
      String? password = await TwoFactorAuth.check2fa();
      if (password == null) {
        if (mounted) {
          await TwoFactorRequiredDialog.show(context);
        }
        return;
      }

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
          await TwoFactorAuth.updateBiometricSetting(true);
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
          await TwoFactorAuth.updateBiometricSetting(false);
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
      // Check if 2FA password exists
      String? password = await TwoFactorAuth.check2fa();
      if (password == null) {
        if (mounted) {
          await TwoFactorRequiredDialog.show(context);
        }
        return;
      }

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
          await TwoFactorAuth.updateTwoFactorSetting(true);
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
          await TwoFactorAuth.updateTwoFactorSetting(false);
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

    ReauthenticationDialog.show(context);
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
              CustomSwitchTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID',
                value: _biometricEnabled,
                onChanged: _handleBiometricToggle,
              ),
              CustomSwitchTile(
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

                      PasswordNotAvailableDialog.show(context, provider);
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

  void _showDeleteAccountDialog() {
    DeleteAccountDialog.show(
      context,
      localAuth: _localAuth,
      onReauthenticationRequired: _showReauthenticationDialog,
    );
  }
}

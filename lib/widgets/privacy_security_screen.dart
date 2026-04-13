// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/custom_switch_tile.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/components/dialogs/delete_account_dialog.dart';
import 'package:app_tact/components/dialogs/password_not_available_dialog.dart';
import 'package:app_tact/components/dialogs/reauthentication_dialog.dart';
import 'package:app_tact/components/dialogs/two_factor_required_dialog.dart';
import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/models/two_factor_auth.dart';
import 'package:app_tact/theme/app_theme.dart';
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
  final bool highlightSetup;
  const PrivacySecurityScreen({super.key, this.highlightSetup = false});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _twoFactorSetupKey = GlobalKey();
  bool _highlight2fa = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    if (widget.highlightSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Wait for the push-navigation slide animation to complete
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        final ctx = _twoFactorSetupKey.currentContext;
        if (ctx != null) {
          await Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.25,
          );
        }
        if (!mounted) return;
        setState(() => _highlight2fa = true);
        await Future.delayed(const Duration(milliseconds: 1600));
        if (mounted) setState(() => _highlight2fa = false);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        // Re-check: user may have just completed setup inside the dialog
        if (!mounted) return;
        final newPassword = await TwoFactorAuth.check2fa();
        if (newPassword == null) return; // still not set up
        // Fall through to enable the toggle
        await TwoFactorAuth.updateTwoFactorSetting(true);
        if (mounted) setState(() => _twoFactorEnabled = true);
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
      decoration: BoxDecoration(
        gradient: context.screenGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context).privSecTitle,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.all(20.w),
            children: [
              SectionTitle(AppLocalizations.of(context).privSecSectionAuth),
              CustomSwitchTile(
                icon: Icons.fingerprint,
                title: AppLocalizations.of(context).privSecBiometricTitle,
                subtitle: AppLocalizations.of(context).privSecBiometricSubtitle,
                value: _biometricEnabled,
                onChanged: _handleBiometricToggle,
              ),
              CustomSwitchTile(
                icon: Icons.security,
                title: AppLocalizations.of(context).privSecTwoFactorTitle,
                subtitle: AppLocalizations.of(context).privSecTwoFactorSubtitle,
                value: _twoFactorEnabled,
                onChanged: _handleTwoFactorToggle,
              ),
              AnimatedContainer(
                key: _twoFactorSetupKey,
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _highlight2fa
                      ? const Color(0xFF7C6BFF).withOpacity(0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: CustomSettingTile(
                  icon: Icons.pin_outlined,
                  title: AppLocalizations.of(context).privSecSetTwoFactorTitle,
                  subtitle:
                      AppLocalizations.of(context).privSecSetTwoFactorSubtitle,
                  onTap: () async {
                    final result = await Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TwoFactorSetupScreen(),
                      ),
                    );
                    // TwoFactorSetupScreen pops with the password string on success
                    if (!mounted) return;
                    if (result != null && result != false) {
                      await TwoFactorAuth.updateTwoFactorSetting(true);
                      setState(() => _twoFactorEnabled = true);
                    }
                  },
                ),
              ),
              SizedBox(height: 20.h),
              SectionTitle(AppLocalizations.of(context).privSecSectionPassword),
              CustomSettingTile(
                icon: Icons.lock_outline,
                title: AppLocalizations.of(context).privSecChangePasswordTitle,
                subtitle:
                    AppLocalizations.of(context).privSecChangePasswordSubtitle,
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
              SectionTitle(
                  AppLocalizations.of(context).privSecSectionPrivacyPolicy),
              CustomSettingTile(
                icon: Icons.policy_outlined,
                title: AppLocalizations.of(context).privSecPrivacyPolicyTitle,
                subtitle:
                    AppLocalizations.of(context).privSecPrivacyPolicySubtitle,
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
                title: AppLocalizations.of(context).privSecTermsTitle,
                subtitle: AppLocalizations.of(context).privSecTermsSubtitle,
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
              SectionTitle(
                  AppLocalizations.of(context).privSecSectionDataPrivacy),
              CustomSettingTile(
                icon: Icons.download_outlined,
                title: AppLocalizations.of(context).privSecDownloadDataTitle,
                subtitle:
                    AppLocalizations.of(context).privSecDownloadDataSubtitle,
                onTap: () {
                  MessageUtils.showSuccessMessage(
                    context,
                    'Data export will be sent to your email',
                  );
                },
              ),
              CustomSettingTile(
                icon: Icons.delete_outline,
                title: AppLocalizations.of(context).privSecDeleteAccountTitle,
                subtitle:
                    AppLocalizations.of(context).privSecDeleteAccountSubtitle,
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

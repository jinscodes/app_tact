// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:app_tact/colors.dart';
import 'package:app_tact/services/account_deletion_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';

class DeleteAccountDialog extends StatelessWidget {
  final LocalAuthentication localAuth;
  final Function() onReauthenticationRequired;

  const DeleteAccountDialog({
    super.key,
    required this.localAuth,
    required this.onReauthenticationRequired,
  });

  static Future<void> show(
    BuildContext context, {
    required LocalAuthentication localAuth,
    required Function() onReauthenticationRequired,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DeleteAccountDialog(
        localAuth: localAuth,
        onReauthenticationRequired: onReauthenticationRequired,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              bool canCheckBiometrics = await localAuth.canCheckBiometrics;
              bool isDeviceSupported = await localAuth.isDeviceSupported();

              if (!canCheckBiometrics || !isDeviceSupported) {
                if (context.mounted) {
                  MessageUtils.showErrorMessage(
                    context,
                    'Biometric authentication is required to delete account',
                  );
                }
                return;
              }

              bool authenticated = await localAuth.authenticate(
                localizedReason: 'Authenticate to delete your account',
                options: const AuthenticationOptions(
                  stickyAuth: true,
                  biometricOnly: true,
                ),
              );

              if (!authenticated) {
                return;
              }

              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await AccountDeletionService.performAccountDeletion(user);

                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              }
            } on FirebaseAuthException catch (e) {
              print('FirebaseAuthException: ${e.code}');
              if (e.code == 'requires-recent-login') {
                print('Reauthentication required, showing dialog...');
                if (context.mounted) {
                  onReauthenticationRequired();
                } else {
                  print('Context not mounted, cannot show dialog');
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
    );
  }
}

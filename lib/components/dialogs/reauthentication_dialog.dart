// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:app_tact/colors.dart';
import 'package:app_tact/services/account_deletion_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReauthenticationDialog extends StatefulWidget {
  const ReauthenticationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ReauthenticationDialog(),
    );
  }

  @override
  State<ReauthenticationDialog> createState() => _ReauthenticationDialogState();
}

class _ReauthenticationDialogState extends State<ReauthenticationDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    String password = _passwordController.text.trim();

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

        if (mounted) {
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

          await AccountDeletionService.performAccountDeletion(currentUser);

          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Reauthentication error: ${e.code}');
      if (mounted) {
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
      if (mounted) {
        Navigator.pop(context);
        MessageUtils.showErrorMessage(
          context,
          'Failed to authenticate: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            controller: _passwordController,
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
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMedium),
          ),
        ),
        TextButton(
          onPressed: _handleConfirm,
          child: Text(
            'Confirm',
            style: TextStyle(color: AppColors.errorRed),
          ),
        ),
      ],
    );
  }
}

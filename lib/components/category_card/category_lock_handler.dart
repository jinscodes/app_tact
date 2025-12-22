import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class CategoryLockHandler {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> toggleLock({
    required BuildContext context,
    required bool currentLockState,
    required Future<void> Function(bool newState) onLockChanged,
  }) async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        if (context.mounted) {
          MessageUtils.showErrorMessage(
            context,
            'Biometric authentication is not available on this device',
          );
        }
        return false;
      }

      bool authenticated = await _localAuth.authenticate(
        localizedReason: currentLockState
            ? 'Authenticate to unlock category'
            : 'Authenticate to lock category',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && context.mounted) {
        final newLockState = !currentLockState;

        await Future.delayed(const Duration(milliseconds: 1200));

        if (!context.mounted) return false;

        MessageUtils.showSuccessAnimation(
          context,
          message: newLockState ? 'Category Locked!' : 'Category Unlocked!',
        );

        await onLockChanged(newLockState);

        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        MessageUtils.showErrorMessage(
          context,
          'Failed to authenticate: ${e.toString()}',
        );
      }
      return false;
    }
  }
}

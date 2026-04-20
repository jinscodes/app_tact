import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static final ValueNotifier<bool> isAuthenticating =
      ValueNotifier<bool>(false);

  /// Internal guard to block re-entrant calls before [isAuthenticating] is set.
  static bool _authInProgress = false;

  static const Set<String> _silentCancellationCodes = {
    'usercanceled',
    'usercancelled',
    'systemcanceled',
    'auth_in_progress',
  };

  static const Set<String> _notAvailableCodes = {
    'notavailable',
  };

  static const Set<String> _notEnrolledCodes = {
    'notenrolled',
  };

  static Future<bool> authenticate({
    required BuildContext context,
    required LocalAuthentication localAuth,
    required String localizedReason,
    required String unavailableMessage,
    required String notEnrolledMessage,
    String failureMessage = 'Authentication failed. Please try again.',
    AuthenticationOptions options = const AuthenticationOptions(
      stickyAuth: true,
      biometricOnly: true,
    ),
  }) async {
    // Use a plain bool for the early guard so we don't trigger ValueNotifier
    // listeners (and a full rebuild) before the system dialog is ready.
    if (_authInProgress) {
      return false;
    }
    _authInProgress = true;

    try {
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        if (context.mounted) {
          MessageUtils.showErrorMessage(context, unavailableMessage);
        }
        return false;
      }

      // Set the notifier RIGHT before the system dialog so the overlay and
      // the Face ID prompt appear in the same visual frame — no flicker.
      isAuthenticating.value = true;
      return await localAuth.authenticate(
        localizedReason: localizedReason,
        options: options,
      );
    } on PlatformException catch (error) {
      final normalizedCode = error.code.toLowerCase();

      if (_silentCancellationCodes.contains(normalizedCode)) {
        return false;
      }

      if (_notAvailableCodes.contains(normalizedCode)) {
        if (context.mounted) {
          MessageUtils.showErrorMessage(context, unavailableMessage);
        }
        return false;
      }

      if (_notEnrolledCodes.contains(normalizedCode)) {
        if (context.mounted) {
          MessageUtils.showErrorMessage(context, notEnrolledMessage);
        }
        return false;
      }

      if (context.mounted) {
        MessageUtils.showErrorMessage(context, failureMessage);
      }
      return false;
    } catch (_) {
      if (context.mounted) {
        MessageUtils.showErrorMessage(context, failureMessage);
      }
      return false;
    } finally {
      _authInProgress = false;
      isAuthenticating.value = false;
    }
  }
}

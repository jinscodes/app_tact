// ignore_for_file: deprecated_member_use

import 'package:app_tact/components/sheet_theme.dart';
import 'package:app_tact/models/two_factor_auth.dart';
import 'package:app_tact/services/biometric_auth_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:app_tact/widgets/privacy_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';

class CategoryLockHandler {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticateForLockChange({
    required BuildContext context,
    required bool currentLockState,
  }) async {
    // Check if 2FA is registered before allowing lock/unlock
    if (!await _has2fa()) {
      if (!context.mounted) return false;

      // Show bottom sheet; returns true if user chose "Go to Settings"
      final goToSettings = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: kSheetBarrier,
        enableDrag: true,
        builder: (ctx) => _TwoFactorPromptSheet(
          onEnable: () => Navigator.of(ctx).pop(true),
          onDismiss: () => Navigator.of(ctx).pop(false),
        ),
      );

      if (goToSettings == true && context.mounted) {
        // Navigate to Privacy & Security and wait for the user to return
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PrivacySecurityScreen(highlightSetup: true),
          ),
        );

        // Re-check: if user set up 2FA, fall through to lock flow
        if (!context.mounted) return false;
        if (!await _has2fa()) return false;
        // 2FA now set up – continue below
      } else {
        return false;
      }
    }

    // ── 2FA is present — proceed with biometric lock/unlock ──────────────────
    final authenticated = await BiometricAuthService.authenticate(
      context: context,
      localAuth: _localAuth,
      localizedReason: currentLockState
          ? 'Authenticate to unlock category'
          : 'Authenticate to lock category',
      unavailableMessage: 'Face ID is not available.',
      notEnrolledMessage:
          'No biometric authentication is set up on this device.',
    );

    debugPrint('Face ID result: $authenticated');

    return authenticated;
  }

  /// Returns true if the user has a 2FA password registered.
  Future<bool> _has2fa() async {
    final password = await TwoFactorAuth.check2fa();
    return password != null;
  }
}

// ── Bottom-sheet prompt ───────────────────────────────────────────────────────

class _TwoFactorPromptSheet extends StatelessWidget {
  final VoidCallback onEnable;
  final VoidCallback onDismiss;

  const _TwoFactorPromptSheet({
    required this.onEnable,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(color: context.sheetBorder, width: 1),
        ),
      ),
      padding:
          EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomPad > 0 ? bottomPad : 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.sheetHandleColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Icon
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: const Color(0xFF7C6BFF).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFF7C6BFF).withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.lock_outline_rounded,
                color: const Color(0xFF7C6BFF),
                size: 26.sp,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Text(
            'Set up 2FA to lock categories',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8.h),

          // Description
          Text(
            'Add extra security before locking your links.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 28.h),

          // Primary button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFB93CFF), Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C6BFF).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: onEnable,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Go to Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),

          // Secondary button
          TextButton(
            onPressed: onDismiss,
            child: Text(
              'Not now',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

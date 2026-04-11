// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:app_tact/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Design tokens (matches login/signup) ────────────────────────────────────
const _kBg = Color(0xFF0F0F0F);
const _kAccent = Color(0xFF7C6BFF);
const _kSurface = Color(0xFF1A1A1A);
const _kBorder = Color(0x1FFFFFFF);
const _kTextPrimary = Colors.white;
const Color _kTextSecondary = Color(0xFF8A8A8E);

/// Cooldown between resend attempts (seconds).
const int _kResendCooldown = 60;

/// How often the screen auto-polls Firebase for verification status.
const Duration _kPollInterval = Duration(seconds: 5);

// ─────────────────────────────────────────────────────────────────────────────
/// Shown immediately after email sign-up (or when a signed-in user's email
/// is still unverified) so the user can verify before accessing the app.
///
/// Flow:
///   1. Auto-sends verification email on first load (handled by caller).
///   2. Polls Firebase every [_kPollInterval] for verified status.
///   3. "I've verified" button forces an immediate re-check.
///   4. "Resend" button resends the email with a [_kResendCooldown]-second cooldown.
///   5. On success → pushes /home, replacing the entire stack.
///   6. "Different account" → signs out and pushes /login.
// ─────────────────────────────────────────────────────────────────────────────
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();

  // Timers
  Timer? _pollTimer;
  Timer? _cooldownTimer;

  // UI state
  bool _isChecking = false; // "I've verified" button spinner
  bool _isSending = false; // Resend button spinner
  bool _justSent = false; // Brief "✓ Sent!" feedback label
  String? _errorMessage;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _logState('Screen opened');
    _startPolling();
    // Always attempt a send when the screen opens, regardless of how the
    // user got here (signup → /verify, unverified login → /verify, or
    // cold-start via AuthWrapper). If Firebase rate-limits us, that means
    // an email was already sent very recently — we treat that as OK and
    // start the resend cooldown so the UI shows the right state.
    _sendInitialEmail();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String get _currentEmail =>
      FirebaseAuth.instance.currentUser?.email ?? 'your email';

  bool get _resendEnabled => _cooldownSeconds == 0 && !_isSending;

  void _logState(String tag) {
    final user = FirebaseAuth.instance.currentUser;
    print('[EmailVerification] $tag | '
        'email=${user?.email} | '
        'emailVerified=${user?.emailVerified} | '
        'uid=${user?.uid}');
  }

  // ─── Initial email send ──────────────────────────────────────────────────

  /// Silently sends a verification email when the screen first opens.
  /// Errors are handled quietly:
  ///   • too-many-requests → an email was just sent; start the cooldown
  ///     so the Resend button shows the right disabled state.
  ///   • anything else → log and ignore; user can tap Resend manually.
  Future<void> _sendInitialEmail() async {
    try {
      await _authService.sendEmailVerification();
      print('[EmailVerification] ✅ Initial email sent to $_currentEmail');
      if (mounted) {
        setState(() => _justSent = true);
        _startCooldown();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        // A recent send already happened — just lock the resend button
        // so the user understands they need to wait.
        print(
            '[EmailVerification] Initial send rate-limited — starting cooldown');
        if (mounted) _startCooldown();
      } else {
        print(
            '[EmailVerification] Initial send error: ${e.code} — ${e.message}');
        // Don't surface this to the UI; the Resend button is still available.
      }
    } catch (e) {
      print('[EmailVerification] Initial send unexpected error: $e');
    }
  }

  // ─── Auto-polling ─────────────────────────────────────────────────────────

  /// Starts a periodic timer that silently re-checks verification so the user
  /// doesn't have to tap "I've verified" manually.
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer =
        Timer.periodic(_kPollInterval, (_) => _checkVerification(auto: true));
  }

  // ─── Check verification ───────────────────────────────────────────────────

  /// Reloads the Firebase user and checks [emailVerified].
  ///
  /// [auto] = true means the call came from the poll timer — no spinner,
  /// no error message on failure (silently retries next tick).
  Future<void> _checkVerification({bool auto = false}) async {
    if (_isChecking) return; // prevent overlapping manual taps

    if (!auto) {
      setState(() {
        _isChecking = true;
        _errorMessage = null;
      });
    }

    try {
      final verified = await _authService.reloadAndCheckVerification();
      _logState('Check result — verified=$verified');

      if (verified && mounted) {
        _pollTimer?.cancel();
        _cooldownTimer?.cancel();
        print('[EmailVerification] ✅ Verified — navigating to /home');
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (e) {
      print('[EmailVerification] Check error: $e');
      if (!auto && mounted) {
        setState(() =>
            _errorMessage = 'Could not check verification status. Try again.');
      }
    } finally {
      if (!auto && mounted) setState(() => _isChecking = false);
    }
  }

  // ─── Resend email ─────────────────────────────────────────────────────────

  Future<void> _resendEmail() async {
    if (!_resendEnabled) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _justSent = false;
    });

    try {
      await _authService.sendEmailVerification();
      print('[EmailVerification] ✅ Resend success → $_currentEmail');
      if (mounted) {
        setState(() => _justSent = true);
        _startCooldown();
      }
    } on FirebaseAuthException catch (e) {
      print(
          '[EmailVerification] Resend FirebaseAuthException: ${e.code} — ${e.message}');
      if (mounted) setState(() => _errorMessage = _resendError(e.code));
    } catch (e) {
      print('[EmailVerification] Resend unexpected error: $e');
      if (mounted) setState(() => _errorMessage = 'Failed to send. Try again.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _resendError(String code) {
    switch (code) {
      case 'too-many-requests':
        return 'Too many attempts. Please wait before trying again.';
      case 'user-not-found':
      case 'user-disabled':
        return 'Account issue detected. Please sign in again.';
      default:
        return 'Failed to send verification email. Please try again.';
    }
  }

  /// Counts down [_kResendCooldown] seconds to prevent resend spam.
  void _startCooldown() {
    setState(() => _cooldownSeconds = _kResendCooldown);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds = (_cooldownSeconds - 1).clamp(0, _kResendCooldown);
        if (_cooldownSeconds == 0) t.cancel();
      });
    });
  }

  // ─── Sign out ─────────────────────────────────────────────────────────────

  Future<void> _signOut() async {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    print('[EmailVerification] User chose to sign out');
    await _authService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 64.h),

                // ─ Email icon ─
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: _kBorder),
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 36.r,
                    color: _kAccent,
                  ),
                ),
                SizedBox(height: 28.h),

                // ─ Headline ─
                Text(
                  'Check your inbox',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12.h),

                // ─ Sub-copy ─
                Text(
                  'We sent a verification link to',
                  style: TextStyle(fontSize: 14.sp, color: _kTextSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  _currentEmail,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap the link in the email, then come back\nand tap the button below.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _kTextSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),

                // ─ Spam hint ─
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1A10),
                    borderRadius: BorderRadius.circular(10.r),
                    border:
                        Border.all(color: const Color(0xFF4A420A), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14.r, color: const Color(0xFFD4A017)),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Can\'t find the email? Check your spam or junk folder.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFFD4A017),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height: 28.h), // reduced from 36 since we added the hint

                // ─ Error banner ─
                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!),
                  SizedBox(height: 16.h),
                ],

                // ─ Primary CTA: "I've verified" ─
                _PrimaryButton(
                  label: _isChecking ? 'Checking…' : "I've verified my email",
                  isLoading: _isChecking,
                  onTap: () => _checkVerification(),
                ),
                SizedBox(height: 12.h),

                // ─ Secondary: Resend ─
                _ResendButton(
                  cooldownSeconds: _cooldownSeconds,
                  isSending: _isSending,
                  justSent: _justSent,
                  onTap: _resendEmail,
                ),

                const Spacer(),

                // ─ Footer: sign out ─
                GestureDetector(
                  onTap: _signOut,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Text(
                      'Use a different account',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: _kTextSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: _kTextSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: _kAccent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResendButton extends StatelessWidget {
  const _ResendButton({
    required this.cooldownSeconds,
    required this.isSending,
    required this.justSent,
    required this.onTap,
  });

  final int cooldownSeconds;
  final bool isSending;
  final bool justSent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool onCooldown = cooldownSeconds > 0;
    final bool disabled = onCooldown || isSending;

    final String label = isSending
        ? 'Sending…'
        : onCooldown
            ? 'Resend in ${cooldownSeconds}s'
            : justSent
                ? '✓ Email sent — check your inbox'
                : 'Resend verification email';

    final Color textColor = disabled ? const Color(0xFF555559) : _kAccent;

    final Color borderColor =
        disabled ? const Color(0xFF2A2A2E) : const Color(0x33FFFFFF);

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: isSending
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(
                  color: _kAccent,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1414),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF5C2020)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFFFF6B6B),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

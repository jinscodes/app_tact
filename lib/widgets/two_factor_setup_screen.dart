// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/models/two_factor_auth.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  bool _isLoading = false;
  int _currentStep = 0;
  String _firstPassword = '';
  String? _existingPassword;
  bool _isCheckingExisting = true;

  // Tracks last code length so _PinDots get fresh keys on step change
  String _displayCode = '';

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
    _checkExistingPassword();
  }

  Future<void> _checkExistingPassword() async {
    final password = await TwoFactorAuth.check2fa();
    if (!mounted) return;
    setState(() {
      _existingPassword = password;
      _currentStep = password != null ? 0 : 1;
      _isCheckingExisting = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _shake() {
    HapticFeedback.mediumImpact();
    _shakeCtrl.forward(from: 0);
  }

  void _clearAndRefocus() {
    _codeController.clear();
    setState(() => _displayCode = '');
    _focusNode.requestFocus();
  }

  void _handleNext() {
    final code = _codeController.text;

    if (_currentStep == 0) {
      if (TwoFactorAuth.verify2fa(code, _existingPassword)) {
        setState(() {
          _currentStep = 1;
          _existingPassword = null;
        });
        _clearAndRefocus();
      } else {
        _shake();
        MessageUtils.showErrorMessage(
            context, 'Incorrect password. Please try again.');
        _clearAndRefocus();
      }
    } else if (_currentStep == 1) {
      setState(() {
        _firstPassword = code;
        _currentStep = 2;
      });
      _clearAndRefocus();
    } else {
      if (!TwoFactorAuth.matchPasswords(code, _firstPassword)) {
        _shake();
        MessageUtils.showErrorMessage(
            context, 'Passwords do not match. Please try again.');
        setState(() {
          _currentStep = 1;
          _firstPassword = '';
        });
        _clearAndRefocus();
        return;
      }
      _saveToFirebase(code);
    }
  }

  Future<void> _saveToFirebase(String password) async {
    setState(() => _isLoading = true);
    try {
      await TwoFactorAuth.save2fa(password);
      if (mounted) {
        MessageUtils.showSuccessMessage(
            context, 'Two-factor authentication password set successfully');
        Navigator.pop(context, password);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _shake();
        MessageUtils.showErrorMessage(
            context, 'Failed to save password: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingExisting) {
      return Container(
        decoration: BoxDecoration(gradient: context.screenGradient),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF7C6BFF)),
          ),
        ),
      );
    }

    final String title;
    final String description;
    final bool showStepDots;

    if (_currentStep == 0) {
      title = 'Verify Password';
      description = 'Enter your current 6-digit 2FA password.';
      showStepDots = false;
    } else if (_currentStep == 1) {
      title = 'Create a Password';
      description = 'Set a 6-digit password for two-factor authentication.';
      showStepDots = true;
    } else {
      title = 'Confirm Password';
      description = 'Re-enter your password to confirm.';
      showStepDots = true;
    }

    return Container(
      decoration: BoxDecoration(gradient: context.screenGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.textPrimary, size: 20.sp),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: Text(
            'Setup 2FA',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon badge
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shield_outlined,
                        size: 22.sp, color: AppColors.accentPurple),
                  ),
                  SizedBox(height: 14.h),

                  // Title — crossfades when step changes
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      title,
                      key: ValueKey(title),
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Description — crossfades when step changes
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      description,
                      key: ValueKey(description),
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // PIN dots + invisible capture field
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (ctx, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value, 0),
                      child: child,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _focusNode.requestFocus(),
                      child: SizedBox(
                        height: 44.h,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Visual dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                6,
                                (i) => _PinDot(
                                  key: ValueKey('$_currentStep-$i'),
                                  filled: i < _displayCode.length,
                                ),
                              ),
                            ),
                            // Invisible input that drives the dots
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0,
                                child: TextField(
                                  controller: _codeController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (v) {
                                    HapticFeedback.selectionClick();
                                    setState(() => _displayCode = v);
                                    if (v.length == 6 && !_isLoading) {
                                      _handleNext();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Step dots or loading indicator — fixed height so layout is stable
                  SizedBox(
                    height: 20.h,
                    child: _isLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFF7C6BFF),
                            ),
                          )
                        : showStepDots
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(2, (i) {
                                  final active = _currentStep == i + 1;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 3.w),
                                    width: active ? 16.w : 5.w,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? AppColors.accentPurple
                                          : context.textSecondary
                                              .withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                  );
                                }),
                              )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated PIN dot ────────────────────────────────────────────────────────

class _PinDot extends StatefulWidget {
  final bool filled;
  const _PinDot({super.key, required this.filled});

  @override
  State<_PinDot> createState() => _PinDotState();
}

class _PinDotState extends State<_PinDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    // If pre-filled (e.g. after step change with restored value), snap to full
    if (widget.filled) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_PinDot old) {
    super.didUpdateWidget(old);
    if (widget.filled && !old.filled) {
      _ctrl.forward(from: 0); // pop in
    } else if (!widget.filled && old.filled) {
      _ctrl.value = 0; // instant clear (backspace feel)
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 14.w,
      height: 14.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.filled
              ? AppColors.accentPurple
              : AppColors.accentPurple.withOpacity(0.25),
          width: 1.5,
        ),
        shape: BoxShape.circle,
      ),
      // Inner fill scales in with easeOutBack for a satisfying pop
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, __) => Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.accentPurple,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

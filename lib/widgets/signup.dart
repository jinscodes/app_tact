// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:ui';

import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0F0F0F);
const _kAccent = Color(0xFF7C6BFF);
const _kSurface = Color(0xFF1A1A1A);
const _kBorder = Color(0x1FFFFFFF); // 12 % white
const _kBorderFocused = _kAccent;
const _kTextPrimary = Colors.white;
const Color _kTextSecondary = Color(0xFF8A8A8E);
const _kDivider = Color(0x14FFFFFF); // 8 % white

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();

  // Step 1
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 2
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  int _step = 0; // 0 = email step, 1 = password step
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  // Validation errors
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  // Password strength (0–4)
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
    // Rebuild the step-1 UI reactively when the email field changes
    // so the Gmail hint banner and button swap appear immediately.
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Triggers a rebuild whenever the email field changes so the Gmail
  // hint and button-swap update in real time.
  void _onEmailChanged() => setState(() {});

  bool get _isGmailAddress =>
      _emailController.text.trim().toLowerCase().endsWith('@gmail.com');

  // ─── Password strength ───────────────────────────────────────────────────

  void _updateStrength() {
    final p = _passwordController.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    setState(() => _passwordStrength = score);
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1:
        return const Color(0xFFFF453A);
      case 2:
        return const Color(0xFFFF9F0A);
      case 3:
        return const Color(0xFF30D158);
      case 4:
        return const Color(0xFF30D158);
      default:
        return Colors.transparent;
    }
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  // ─── Navigation ──────────────────────────────────────────────────────────

  // If the user entered a Gmail address, skip the password step entirely
  // and go straight to Google Sign-In — no duplicate accounts possible.
  Future<void> _goToStep2() async {
    setState(() {
      _nameError = null;
      _emailError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final emailRx = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');

    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter your name');
      return;
    }
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      return;
    }
    if (!emailRx.hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }

    // Gmail → skip password step, use Google Sign-In directly.
    if (_isGmailAddress) {
      debugPrint('[Signup] Gmail detected — auto-routing to Google Sign-In');
      await _googleSignUp();
      return;
    }

    setState(() => _step = 1);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_step == 1) {
      setState(() => _step = 0);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.maybePop(context);
    }
  }

  // ─── Sign-up actions ─────────────────────────────────────────────────────

  Future<void> _submitSignup() async {
    setState(() {
      _passwordError = null;
      _confirmError = null;
    });

    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      setState(() => _passwordError = 'Minimum 6 characters required');
      return;
    }
    if (password != confirm) {
      setState(() => _confirmError = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());

        // NOTE: We intentionally do NOT send the verification email here.
        // EmailVerificationScreen.initState() sends it automatically when
        // the screen opens, and handles rate-limiting cleanly.
        // Sending here AND in the screen caused the double-send / too-many-requests
        // error that was observed previously.

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('info')
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'userId': user.uid,
          'memberSince': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'signupType': 'email',
        });

        // Keep the user signed in and send them to the verification screen.
        // Do NOT sign out here — EmailVerificationScreen needs the session
        // to poll for emailVerified and to resend the email if needed.
        debugPrint(
            '[Signup] ✅ Account created for ${user.email} — redirecting to verify screen');

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/verify', (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Ask Firebase which providers are actually registered for this email
        // instead of guessing from the address format.
        final email = _emailController.text.trim();
        final providers = await _authService.fetchProvidersForEmail(email);
        debugPrint('[Signup] email-already-in-use providers=$providers');

        if (mounted) _showProviderConflictSheet(providers);
        return;
      }

      String msg = 'Sign-up failed. Please try again.';
      if (e.code == 'invalid-email') msg = 'Invalid email address.';
      if (e.code == 'weak-password') msg = 'Password is too weak.';
      if (mounted) MessageUtils.showErrorMessage(context, msg);
    } catch (e) {
      if (mounted)
        MessageUtils.showErrorMessage(context, 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result?.user != null) {
        final user = result!.user!;
        await user.reload();
        final fresh = FirebaseAuth.instance.currentUser;
        if (fresh == null) return;

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fresh.uid)
            .collection('profile')
            .doc('info')
            .get();

        if (!doc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(fresh.uid)
              .collection('profile')
              .doc('info')
              .set({
            'name': fresh.displayName ?? 'User',
            'email': fresh.email,
            'userId': fresh.uid,
            'memberSince': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
            'signupType': 'google',
          });
        }

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '[GoogleSignUp] FirebaseAuthException: ${e.code} — ${e.message}');
      if (!mounted) return;
      if (e.code == 'account-exists-with-different-credential') {
        MessageUtils.showErrorMessage(
          context,
          'An account already exists with this email. Try signing in with email & password.',
        );
      } else {
        MessageUtils.showErrorMessage(
            context, 'Google sign-up failed. Please try again.');
      }
    } catch (e) {
      debugPrint('[GoogleSignUp] Unexpected error: $e');
      if (mounted) {
        MessageUtils.showErrorMessage(
            context, 'Google sign-up failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Gmail hint ───────────────────────────────────────────────────────────

  /// Subtle banner shown below the email field when a gmail.com address is
  /// detected. Explains that the user will be signed in via Google, not via
  /// email+password — sets clear expectations before they tap the button.
  List<Widget> _buildGmailHint() {
    return [
      SizedBox(height: 10.h),
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            // Subtle purple tint matching the accent
            color: const Color(0x197C6BFF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0x337C6BFF), width: 1),
          ),
          child: Row(
            children: [
              // Google "G" mark
              const SizedBox(width: 18, height: 18, child: _GoogleLogo()),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Looks like a Google account — we\'ll sign you in with Google.',
                  style: TextStyle(
                    color: const Color(0xFFB8AFFF),
                    fontSize: 12.5.sp,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  // ─── Provider conflict ────────────────────────────────────────────────────

  /// Shows a bottom sheet that tells the user which provider their email is
  /// already registered with and gives them a single clear action to take.
  void _showProviderConflictSheet(List<String> providers) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (_) => _ProviderConflictSheet(
        email: _emailController.text.trim(),
        providers: providers,
        onGoogleSignIn: () async {
          Navigator.pop(context);
          await _googleSignUp();
        },
        onGoToLogin: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Column(
              children: [
                // ─ Top bar ─
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 8.h, 20.w, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18.sp),
                        onPressed: _goBack,
                        splashRadius: 20,
                      ),
                      const Spacer(),
                      // Step dots
                      _StepDot(active: _step == 0),
                      SizedBox(width: 6.w),
                      _StepDot(active: _step == 1),
                    ],
                  ),
                ),
                // ─ Pages ─
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Step 1: Name + Email ─────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create your\naccount',
              style: TextStyle(
                color: _kTextPrimary,
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.8,
              )),
          SizedBox(height: 10.h),
          Text('Start organizing your links in seconds.',
              style: TextStyle(
                  color: _kTextSecondary, fontSize: 15.sp, height: 1.4)),
          SizedBox(height: 40.h),

          // Name
          _AuthInput(
            controller: _nameController,
            label: 'Full name',
            placeholder: 'Full Name',
            keyboardType: TextInputType.name,
            error: _nameError,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: 16.h),

          // Email
          _AuthInput(
            controller: _emailController,
            label: 'Email address',
            placeholder: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            error: _emailError,
          ),

          // Gmail hint banner — appears as soon as @gmail.com is typed
          if (_isGmailAddress) ..._buildGmailHint(),

          SizedBox(height: 32.h),

          // Continue button — swaps to Google button when gmail is detected
          if (_isGmailAddress)
            _SocialButton(
              icon: _kGoogleIcon,
              label: 'Continue with Google',
              onTap: _isLoading ? null : _goToStep2,
            )
          else
            _AuthButton(
              label: 'Continue',
              isLoading: _isLoading,
              onTap: _goToStep2,
            ),
          SizedBox(height: 28.h),

          // Divider
          _OrDivider(),
          SizedBox(height: 20.h),

          // Google (always visible as fallback)
          if (!_isGmailAddress)
            _SocialButton(
              icon: _kGoogleIcon,
              label: 'Continue with Google',
              onTap: _isLoading ? null : _googleSignUp,
            ),
          if (!_isGmailAddress) SizedBox(height: 32.h),

          // Login link
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14.sp),
                  children: [
                    TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: _kTextSecondary)),
                    TextSpan(
                        text: 'Log in',
                        style: TextStyle(
                            color: _kAccent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Password ─────────────────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set your\npassword',
              style: TextStyle(
                color: _kTextPrimary,
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.8,
              )),
          SizedBox(height: 10.h),
          Text("Choose something you won't forget.",
              style: TextStyle(
                  color: _kTextSecondary, fontSize: 15.sp, height: 1.4)),
          SizedBox(height: 40.h),

          // Password
          _AuthInput(
            controller: _passwordController,
            label: 'Password',
            placeholder: '••••••••',
            obscure: !_passwordVisible,
            error: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _kTextSecondary,
                size: 18.sp,
              ),
              onPressed: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
          ),
          // Strength bar
          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _StrengthBar(strength: _passwordStrength, color: _strengthColor),
            SizedBox(height: 4.h),
            Text(_strengthLabel,
                style: TextStyle(
                    color: _strengthColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500)),
          ],
          SizedBox(height: 16.h),

          // Confirm
          _AuthInput(
            controller: _confirmController,
            label: 'Confirm password',
            placeholder: '••••••••',
            obscure: !_confirmVisible,
            error: _confirmError,
            suffixIcon: IconButton(
              icon: Icon(
                _confirmVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _kTextSecondary,
                size: 18.sp,
              ),
              onPressed: () =>
                  setState(() => _confirmVisible = !_confirmVisible),
            ),
          ),
          SizedBox(height: 32.h),

          _AuthButton(
            label: 'Create Account',
            isLoading: _isLoading,
            onTap: _submitSignup,
          ),
          SizedBox(height: 24.h),

          Center(
            child: Text(
              'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _kTextSecondary, fontSize: 12.sp, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI components (private to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  final bool active;
  const _StepDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 20.w : 6.w,
      height: 6.h,
      decoration: BoxDecoration(
        color: active ? _kAccent : Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }
}

class _AuthInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final TextInputType keyboardType;
  final bool obscure;
  final String? error;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;

  const _AuthInput({
    required this.controller,
    required this.label,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.error,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<_AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<_AuthInput> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;
    final borderColor = hasError
        ? const Color(0xFFFF453A)
        : _focused
            ? _kBorderFocused
            : _kBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: _focused ? _kAccent : _kTextSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: 8.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscure,
            textCapitalization: widget.textCapitalization,
            style: TextStyle(
              color: _kTextPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.22), fontSize: 16.sp),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Text(
            widget.error!,
            style: TextStyle(
                color: const Color(0xFFFF453A),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}

class _AuthButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
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
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            color: _kAccent,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withOpacity(0.30),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: _kDivider, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text('or',
              style: TextStyle(color: _kTextSecondary, fontSize: 13.sp)),
        ),
        Expanded(child: Divider(color: _kDivider, thickness: 1)),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel:
          widget.onTap != null ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: _kBorder, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              SizedBox(width: 10.w),
              Text(
                widget.label,
                style: TextStyle(
                  color: _kTextPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final int strength;
  final Color color;
  const _StrengthBar({required this.strength, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 4.w : 0),
            height: 3.h,
            decoration: BoxDecoration(
              color: i < strength ? color : Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Provider conflict bottom sheet ─────────────────────────────────────────

class _ProviderConflictSheet extends StatefulWidget {
  const _ProviderConflictSheet({
    required this.email,
    required this.providers,
    required this.onGoogleSignIn,
    required this.onGoToLogin,
  });

  final String email;
  final List<String> providers;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGoToLogin;

  @override
  State<_ProviderConflictSheet> createState() => _ProviderConflictSheetState();
}

class _ProviderConflictSheetState extends State<_ProviderConflictSheet> {
  bool _primaryPressed = false;
  bool _secondaryPressed = false;

  bool get _hasGoogle => widget.providers.contains('google.com');
  bool get _hasApple => widget.providers.contains('apple.com');

  String get _headline {
    if (_hasGoogle) return 'Already signed in with Google';
    if (_hasApple) return 'Already signed in with Apple';
    return 'Email already registered';
  }

  String get _body {
    if (_hasGoogle) {
      return 'This email (${widget.email}) is linked to a Google account. Use Google to sign in instead.';
    }
    if (_hasApple) {
      return 'This email (${widget.email}) is linked to an Apple account. Use Apple to sign in instead.';
    }
    return 'An account with ${widget.email} already exists. Head to Login to continue.';
  }

  String get _primaryLabel {
    if (_hasGoogle) return 'Continue with Google';
    if (_hasApple) return 'Continue with Apple';
    return 'Go to Login';
  }

  Widget get _primaryIcon {
    if (_hasGoogle) return const _GoogleLogo();
    if (_hasApple) {
      return Icon(Icons.apple, color: Colors.white, size: 18.sp);
    }
    return Icon(Icons.login_rounded, color: Colors.white, size: 18.sp);
  }

  VoidCallback get _primaryAction {
    if (_hasGoogle) return widget.onGoogleSignIn;
    // Apple sign-in not yet implemented — fall through to login
    return widget.onGoToLogin;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1828).withOpacity(0.92),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
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
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Icon
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: const Color(0x267C6BFF),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: _hasGoogle
                      ? const SizedBox(
                          width: 26, height: 26, child: _GoogleLogo())
                      : _hasApple
                          ? Icon(Icons.apple, color: _kAccent, size: 28.r)
                          : Icon(Icons.email_outlined,
                              color: _kAccent, size: 24.r),
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                _headline,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Body
              Text(
                _body,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 13.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),

              // Primary button
              GestureDetector(
                onTapDown: (_) => setState(() => _primaryPressed = true),
                onTapUp: (_) {
                  setState(() => _primaryPressed = false);
                  _primaryAction();
                },
                onTapCancel: () => setState(() => _primaryPressed = false),
                child: AnimatedScale(
                  scale: _primaryPressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 80),
                  child: Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: _kAccent,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _primaryIcon,
                        SizedBox(width: 8.w),
                        Text(
                          _primaryLabel,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Secondary: Go to Login (always shown except when primary IS login)
              if (_hasGoogle || _hasApple)
                GestureDetector(
                  onTapDown: (_) => setState(() => _secondaryPressed = true),
                  onTapUp: (_) {
                    setState(() => _secondaryPressed = false);
                    widget.onGoToLogin();
                  },
                  onTapCancel: () => setState(() => _secondaryPressed = false),
                  child: AnimatedScale(
                    scale: _secondaryPressed ? 0.97 : 1.0,
                    duration: const Duration(milliseconds: 80),
                    child: Container(
                      width: double.infinity,
                      height: 50.h,
                      alignment: Alignment.center,
                      child: Text(
                        'Go to Login',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.40),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Google "G" icon drawn with text (no asset dependency)
const Widget _kGoogleIcon = _GoogleLogo();

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    void arc(Color c, double start, double sweep, double inset) {
      final paint = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r - inset),
          start, sweep, false, paint);
    }

    const pi = 3.1415926;
    arc(const Color(0xFF4285F4), -pi / 6, pi * 2 / 3, 1.5);
    arc(const Color(0xFF34A853), pi / 2, pi / 2, 1.5);
    arc(const Color(0xFFFBBC05), pi, pi / 2, 1.5);
    arc(const Color(0xFFEA4335), 3 * pi / 2, pi / 3, 1.5);

    // right-side horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r - 1.5, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_GooglePainter old) => false;
}

// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:app_tact/widgets/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Shared design tokens (same as signup.dart)
const _kBg = Color(0xFF0F0F0F);
const _kAccent = Color(0xFF7C6BFF);
const _kSurface = Color(0xFF1A1A1A);
const _kBorder = Color(0x1FFFFFFF);
const _kBorderFocused = _kAccent;
const _kTextPrimary = Colors.white;
const Color _kTextSecondary = Color(0xFF8A8A8E);
const _kDivider = Color(0x14FFFFFF);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result?.user != null) {
        if (!result!.user!.emailVerified) {
          // User exists but hasn't verified — send them to the waiting screen.
          // They remain signed in so the screen can poll for verification.
          print(
              '[Login] User ${result.user!.email} is unverified — routing to /verify');
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/verify', (r) => false);
          }
          return;
        }
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      print('[Login] FirebaseAuthException: ${e.code}');
      if (!mounted) return;

      final email = _emailController.text.trim();
      final isGmail = email.toLowerCase().endsWith('@gmail.com');

      if (e.code == 'account-exists-with-different-credential' ||
          (isGmail &&
              (e.code == 'user-not-found' ||
                  e.code == 'wrong-password' ||
                  e.code == 'invalid-credential'))) {
        // Gmail address → nudge towards Google sign-in
        setState(() {
          _emailError = isGmail
              ? 'This Gmail address may use Google sign-in'
              : 'Incorrect email or password';
          _passwordError = ' ';
        });
        if (isGmail) {
          MessageUtils.showInfoMessage(
            context,
            'Try signing in with the Google button below.',
          );
        }
      } else if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        setState(() {
          _emailError = 'Incorrect email or password';
          _passwordError = ' ';
        });
      } else {
        MessageUtils.showErrorMessage(context, 'Sign-in failed. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result?.user != null && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
      }
    } on FirebaseAuthException catch (e) {
      print('[Login] Google FirebaseAuthException: ${e.code} — ${e.message}');
      if (mounted) {
        if (e.code == 'account-exists-with-different-credential') {
          MessageUtils.showErrorMessage(
            context,
            'An account already exists with this email. Try signing in with email & password.',
          );
        } else {
          MessageUtils.showErrorMessage(
              context, 'Google sign-in failed. Please try again.');
        }
      }
    } catch (e) {
      print('[Login] Google sign-in unexpected error: $e');
      if (mounted)
        MessageUtils.showErrorMessage(
            context, 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Enter your email first');
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        MessageUtils.showSuccessMessage(context, 'Reset link sent to $email');
      }
    } catch (e) {
      if (mounted)
        MessageUtils.showErrorMessage(context, 'Could not send reset email.');
    }
  }

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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─ Headline ─
                  Text('Welcome\nback',
                      style: TextStyle(
                        color: _kTextPrimary,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                        letterSpacing: -1.0,
                      )),
                  SizedBox(height: 10.h),
                  Text('Sign in to continue.',
                      style: TextStyle(
                          color: _kTextSecondary,
                          fontSize: 15.sp,
                          height: 1.4)),
                  SizedBox(height: 44.h),

                  // ─ Email ─
                  _AuthInput(
                    controller: _emailController,
                    label: 'Email address',
                    placeholder: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    error: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),
                  SizedBox(height: 16.h),

                  // ─ Password ─
                  _AuthInput(
                    controller: _passwordController,
                    label: 'Password',
                    placeholder: '••••••••',
                    obscure: !_passwordVisible,
                    error: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
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
                  SizedBox(height: 10.h),

                  // ─ Forgot ─
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _forgotPassword,
                      child: Text('Forgot password?',
                          style: TextStyle(
                              color: _kAccent,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // ─ Sign In button ─
                  _AuthButton(
                    label: 'Sign In',
                    isLoading: _isLoading,
                    onTap: _signIn,
                  ),
                  SizedBox(height: 28.h),

                  // ─ Divider ─
                  _OrDivider(),
                  SizedBox(height: 20.h),

                  // ─ Google ─
                  _SocialButton(
                    icon: const _GoogleLogo(),
                    label: 'Continue with Google',
                    onTap: _isLoading ? null : _googleSignIn,
                  ),
                  SizedBox(height: 36.h),

                  // ─ Sign up link ─
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14.sp),
                          children: [
                            TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: _kTextSecondary)),
                            TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                    color: _kAccent,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Reusable components (private to auth screens)
// ─────────────────────────────────────────────────────────────────────────────

class _AuthInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final TextInputType keyboardType;
  final bool obscure;
  final String? error;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const _AuthInput({
    required this.controller,
    required this.label,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.error,
    this.suffixIcon,
    this.onChanged,
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
    final hasError = widget.error != null && widget.error!.trim().isNotEmpty;
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
            onChanged: widget.onChanged,
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
                        color: Colors.white, strokeWidth: 2.5),
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

  const _SocialButton({required this.icon, required this.label, this.onTap});

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
              Text(widget.label,
                  style: TextStyle(
                      color: _kTextPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 20, height: 20, child: CustomPaint(painter: _GooglePainter()));
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    const pi = 3.1415926;

    void arc(Color c, double start, double sweep) {
      final paint = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r - 1.5),
          start, sweep, false, paint);
    }

    arc(const Color(0xFF4285F4), -pi / 6, pi * 2 / 3);
    arc(const Color(0xFF34A853), pi / 2, pi / 2);
    arc(const Color(0xFFFBBC05), pi, pi / 2);
    arc(const Color(0xFFEA4335), 3 * pi / 2, pi / 3);

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r - 1.5, cy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GooglePainter old) => false;
}

// ignore_for_file: deprecated_member_use

import 'package:app_tact/services/theme_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemePickerScreen extends StatefulWidget {
  const ThemePickerScreen({super.key});

  @override
  State<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<ThemePickerScreen>
    with SingleTickerProviderStateMixin {
  ThemeMode? _selected;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    await ThemeService.setMode(_selected!);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: context.appBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60.h),

                    // ── Header ────────────────────────────────────────────
                    Text(
                      'Choose your look',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Pick a theme to get started. You can always change it later in Settings.',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 15.sp,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // ── Light option ──────────────────────────────────────
                    _ThemeCard(
                      mode: ThemeMode.light,
                      label: 'Light',
                      description: 'Clean and bright',
                      icon: Icons.light_mode_rounded,
                      previewColors: const [
                        Color(0xFFF3F1FF),
                        Color(0xFFEDE9FF)
                      ],
                      selected: _selected == ThemeMode.light,
                      onTap: () => setState(() => _selected = ThemeMode.light),
                    ),

                    SizedBox(height: 16.h),

                    // ── Dark option ───────────────────────────────────────
                    _ThemeCard(
                      mode: ThemeMode.dark,
                      label: 'Dark',
                      description: 'Easy on the eyes',
                      icon: Icons.dark_mode_rounded,
                      previewColors: const [
                        Color(0xFF0B0E1D),
                        Color(0xFF2E2939)
                      ],
                      selected: _selected == ThemeMode.dark,
                      onTap: () => setState(() => _selected = ThemeMode.dark),
                    ),

                    const Spacer(),

                    // ── Confirm button ────────────────────────────────────
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _selected != null ? 1.0 : 0.45,
                      child: GestureDetector(
                        onTap: _selected != null ? _confirm : null,
                        child: Container(
                          height: 54.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Theme preview card ────────────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  final ThemeMode mode;
  final String label;
  final String description;
  final IconData icon;
  final List<Color> previewColors;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.mode,
    required this.label,
    required this.description,
    required this.icon,
    required this.previewColors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7C6BFF);
    final isDarkCard = mode == ThemeMode.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? accent : context.borderColor,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Row(
            children: [
              // Mini preview swatch
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: previewColors,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.06),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24.sp,
                  color: isDarkCard
                      ? Colors.white.withOpacity(0.85)
                      : const Color(0xFF6C5CE7),
                ),
              ),

              SizedBox(width: 16.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      description,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: selected ? accent : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? accent
                        : context.textSecondary.withOpacity(0.35),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check_rounded,
                        color: Colors.white, size: 14.sp)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

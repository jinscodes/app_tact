import 'package:app_tact/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemePickerScreen extends StatefulWidget {
  const ThemePickerScreen({
    super.key,
    this.returnSelectionOnConfirm = false,
  });

  final bool returnSelectionOnConfirm;

  @override
  State<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<ThemePickerScreen>
    with SingleTickerProviderStateMixin {
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
    final controller = ThemeControllerScope.of(context);
    if (!_isSelectableTheme(controller.themeMode)) return;
    await controller.persistThemeSelection();
    if (widget.returnSelectionOnConfirm) {
      if (mounted) {
        Navigator.pop(context, controller.themeMode);
      }
      return;
    }
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
  }

  void _previewTheme(ThemeMode mode) {
    ThemeControllerScope.of(context).setTheme(mode);
  }

  bool _isSelectableTheme(ThemeMode mode) {
    return mode == ThemeMode.light || mode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeControllerScope.of(context);
    final selectedMode = controller.themeMode;
    final canContinue = _isSelectableTheme(selectedMode);

    return PopScope(
      canPop: !widget.returnSelectionOnConfirm,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F6),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 24.h),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.palette_outlined,
                                size: 28,
                                color: Color(0xFF111111),
                              ),
                              SizedBox(height: 18.h),
                              Text(
                                'Choose your look',
                                style: TextStyle(
                                  color: const Color(0xFF111111),
                                  fontSize: 34.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                  letterSpacing: -0.9,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Pick the theme that feels best for your day-to-day use.',
                                style: TextStyle(
                                  color: const Color(0xFF6E6E73),
                                  fontSize: 16.sp,
                                  height: 1.45,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Your choice previews instantly, and you can always change it later in Settings.',
                                style: TextStyle(
                                  color: const Color(0xFF6E6E73),
                                  fontSize: 16.sp,
                                  height: 1.45,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              SizedBox(height: 34.h),
                              _ThemeCard(
                                mode: ThemeMode.light,
                                label: 'Light',
                                description: 'Bright, clear, and airy',
                                icon: Icons.light_mode_rounded,
                                previewColors: const [
                                  Color(0xFFFFFFFF),
                                  Color(0xFFF1F1F4),
                                ],
                                selected: selectedMode == ThemeMode.light,
                                onTap: () => _previewTheme(ThemeMode.light),
                              ),
                              SizedBox(height: 12.h),
                              _ThemeCard(
                                mode: ThemeMode.dark,
                                label: 'Dark',
                                description:
                                    'Calm, focused, and easy on the eyes',
                                icon: Icons.dark_mode_rounded,
                                previewColors: const [
                                  Color(0xFF151515),
                                  Color(0xFF2A2A2E),
                                ],
                                selected: selectedMode == ThemeMode.dark,
                                onTap: () => _previewTheme(ThemeMode.dark),
                              ),
                              const Spacer(),
                              SizedBox(height: 48.h),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: canContinue ? 1.0 : 0.45,
                                child: _IosPrimaryButton(
                                  label: 'Continue',
                                  onTap: canContinue ? _confirm : null,
                                ),
                              ),
                              SizedBox(height: 8.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
    const accent = Color(0xFF111111);
    final isDarkCard = mode == ThemeMode.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDarkCard ? 0.0 : 0.8),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE3E3E8),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54.r,
              height: 54.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: previewColors,
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0x11000000),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 23.sp,
                color: isDarkCard
                    ? Colors.white.withValues(alpha: 0.88)
                    : const Color(0xFF111111),
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
                      color: const Color(0xFF111111),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: const Color(0xFF6E6E73),
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: selected ? accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accent : const Color(0xFFD1D1D6),
                  width: 1.8,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 14.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _IosPrimaryButton extends StatefulWidget {
  const _IosPrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  State<_IosPrimaryButton> createState() => _IosPrimaryButtonState();
}

class _IosPrimaryButtonState extends State<_IosPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isEnabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(999.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
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
    );
  }
}

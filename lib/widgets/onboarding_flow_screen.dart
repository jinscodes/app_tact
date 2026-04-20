import 'package:app_tact/services/post_login_onboarding_service.dart';
import 'package:app_tact/services/theme_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({
    super.key,
    required this.onCompleted,
  });

  final VoidCallback onCompleted;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final PostLoginOnboardingService _onboardingService =
      PostLoginOnboardingService.instance;

  bool _isRunningOnboarding = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _animateToPage(int page) async {
    if (!_pageController.hasClients) return;
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleNotificationStep(
      {required bool requestPermission}) async {
    if (_isRunningOnboarding) return;
    _isRunningOnboarding = true;
    try {
      await _onboardingService.completeNotificationStep(
        requestPermission: requestPermission,
      );
      if (!mounted) return;
      await _animateToPage(1);
    } finally {
      _isRunningOnboarding = false;
    }
  }

  Future<void> _handleSkipOnboarding() async {
    if (_isRunningOnboarding) return;
    _isRunningOnboarding = true;
    try {
      await _onboardingService.completeNotificationStep(
        requestPermission: false,
      );
      await _onboardingService.completeOnboarding();
      if (!mounted) return;
      widget.onCompleted();
    } finally {
      _isRunningOnboarding = false;
    }
  }

  Future<void> _handleThemeContinue() async {
    if (_isRunningOnboarding) return;
    final themeController = ThemeControllerScope.of(context);
    final themeMode = themeController.themeMode;
    if (themeMode != ThemeMode.light && themeMode != ThemeMode.dark) {
      return;
    }

    _isRunningOnboarding = true;
    try {
      await themeController.persistThemeSelection();
      await _onboardingService.markThemeSelected();
      if (!mounted) return;
      await _animateToPage(2);
    } finally {
      _isRunningOnboarding = false;
    }
  }

  Future<void> _handleGetStarted() async {
    if (_isRunningOnboarding) return;
    _isRunningOnboarding = true;
    try {
      await _onboardingService.completeOnboarding();
      if (!mounted) return;
      widget.onCompleted();
    } finally {
      _isRunningOnboarding = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: context.screenGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
                child: Column(
                  children: [
                    SizedBox(height: 6.h),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _NotificationStep(
                            onEnable: () => _handleNotificationStep(
                              requestPermission: true,
                            ),
                            onSkip: _handleSkipOnboarding,
                          ),
                          _ThemeStep(
                            onContinue: _handleThemeContinue,
                          ),
                          _HowToUseStep(
                            onGetStarted: _handleGetStarted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationStep extends StatefulWidget {
  const _NotificationStep({
    required this.onEnable,
    required this.onSkip,
  });

  final VoidCallback onEnable;
  final VoidCallback onSkip;

  @override
  State<_NotificationStep> createState() => _NotificationStepState();
}

class _NotificationStepState extends State<_NotificationStep> {
  bool _notificationToggleEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final iconColor =
        isDark ? Colors.white.withValues(alpha: 0.92) : const Color(0xFF111111);
    final titleColor = isDark ? Colors.white : const Color(0xFF111111);
    final bodyColor =
        isDark ? Colors.white.withValues(alpha: 0.72) : const Color(0xFF6E6E73);
    final toggleInactiveTrack =
        isDark ? Colors.white.withValues(alpha: 0.24) : const Color(0xFFDDDDDD);
    final buttonBg = isDark ? const Color(0xFF8B80FF) : const Color(0xFF111111);
    final skipColor =
        isDark ? Colors.white.withValues(alpha: 0.56) : const Color(0xFF6E6E73);

    return _ScrollableOnboardingStep(
      horizontalPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28.h),
          Icon(
            Icons.notifications_none_rounded,
            size: 24.r,
            color: iconColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'Turn on notifications?',
            style: TextStyle(
              color: titleColor,
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              height: 1.06,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Don\'t miss important activity like updates to your saved links and account changes.',
            style: TextStyle(
              color: bodyColor,
              fontSize: 15.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 7.h),
                  child: Text(
                    'Get reminders, security alerts, and helpful updates when they matter.',
                    style: TextStyle(
                      color: bodyColor,
                      fontSize: 15.sp,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Switch.adaptive(
                value: _notificationToggleEnabled,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF8B80FF),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: toggleInactiveTrack,
                onChanged: (value) {
                  setState(() {
                    _notificationToggleEnabled = value;
                  });
                  if (value) widget.onEnable();
                },
              ),
            ],
          ),
          const Spacer(),
          _IosPrimaryActionButton(
            label: 'Next',
            onTap: widget.onEnable,
            backgroundColor: buttonBg,
          ),
          SizedBox(height: 14.h),
          Center(
            child: _SecondaryActionButton(
              label: 'Skip',
              onTap: widget.onSkip,
              textColor: skipColor,
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _ThemeStep extends StatelessWidget {
  const _ThemeStep({
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final controller = ThemeControllerScope.of(context);
    final selectedMode = controller.themeMode;
    final canContinue =
        selectedMode == ThemeMode.light || selectedMode == ThemeMode.dark;

    return _ScrollableOnboardingStep(
      horizontalPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          const _HeroIcon(
            icon: Icons.auto_awesome_rounded,
            tint: Color(0xFF7C6BFF),
          ),
          SizedBox(height: 28.h),
          Text(
            'Choose your look',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              height: 1.08,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Pick the theme that fits you best. Your choice is previewed instantly across the app.',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 15.sp,
              height: 1.55,
            ),
          ),
          SizedBox(height: 32.h),
          _OnboardingThemeCard(
            mode: ThemeMode.light,
            label: 'Light',
            description: 'Clean and bright',
            icon: Icons.light_mode_rounded,
            previewColors: context.isDark
                ? const [Color(0xFFF3F1FF), Color(0xFFEDE9FF)]
                : const [Color(0xFFCEC7FF), Color(0xFFBDB4FF)],
            selected: selectedMode == ThemeMode.light,
            onTap: () => controller.setTheme(ThemeMode.light),
          ),
          SizedBox(height: 16.h),
          _OnboardingThemeCard(
            mode: ThemeMode.dark,
            label: 'Dark',
            description: 'Focused and calm',
            icon: Icons.dark_mode_rounded,
            previewColors: const [Color(0xFF0B0E1D), Color(0xFF2E2939)],
            selected: selectedMode == ThemeMode.dark,
            onTap: () => controller.setTheme(ThemeMode.dark),
          ),
          const Spacer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: canContinue ? 1 : 0.45,
            child: _PrimaryActionButton(
              label: 'Continue',
              onTap: canContinue ? onContinue : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToUseStep extends StatelessWidget {
  const _HowToUseStep({
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return _ScrollableOnboardingStep(
      horizontalPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Spacer(),
          _PrimaryActionButton(
            label: 'Get Started',
            onTap: onGetStarted,
          ),
        ],
      ),
    );
  }
}

class _ScrollableOnboardingStep extends StatelessWidget {
  const _ScrollableOnboardingStep({
    required this.child,
    this.horizontalPadding = 0,
  });

  final Widget child;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({
    required this.icon,
    required this.tint,
  });

  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: isDark ? 0.14 : 0.12),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: tint.withValues(alpha: isDark ? 0.20 : 0.30),
        ),
      ),
      child: Icon(
        icon,
        color: tint,
        size: 34.r,
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C6BFF).withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.onTap,
    this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? context.textSecondary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _IosPrimaryActionButton extends StatefulWidget {
  const _IosPrimaryActionButton({
    required this.label,
    required this.onTap,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  State<_IosPrimaryActionButton> createState() =>
      _IosPrimaryActionButtonState();
}

class _IosPrimaryActionButtonState extends State<_IosPrimaryActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? const Color(0xFF111111),
            borderRadius: BorderRadius.circular(999.r),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor != null
                    ? widget.backgroundColor!.withValues(alpha: 0.32)
                    : const Color(0x14000000),
                blurRadius: 12,
                offset: const Offset(0, 4),
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

class _OnboardingThemeCard extends StatelessWidget {
  const _OnboardingThemeCard({
    required this.mode,
    required this.label,
    required this.description,
    required this.icon,
    required this.previewColors,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final String label;
  final String description;
  final IconData icon;
  final List<Color> previewColors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7C6BFF);
    final isDarkCard = mode == ThemeMode.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: selected ? accent : context.borderColor,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: accent.withValues(alpha: 0.20),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            if (!context.isDark)
              const BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58.r,
              height: 58.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: previewColors,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: isDarkCard
                    ? Colors.white.withValues(alpha: 0.86)
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
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
                      : context.textSecondary.withValues(alpha: 0.35),
                  width: 2,
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

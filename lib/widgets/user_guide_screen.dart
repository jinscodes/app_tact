import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/services/user_guide_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserGuideScreen extends StatefulWidget {
  const UserGuideScreen({super.key});

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadPreference();
    _animationController.forward();
  }

  Future<void> _loadPreference() async {
    final hideGuide = await UserGuideService.shouldHideUserGuide();
    if (mounted) {
      setState(() => _dontShowAgain = hideGuide);
    }
  }

  Future<void> _handleDone() async {
    await UserGuideService.setHideUserGuide(_dontShowAgain);
    if (!mounted) {
      return;
    }
    MessageUtils.showSuccessMessage(
        context, AppLocalizations.of(context).guideSaved);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final guideItems = <_GuideContentItem>[
      _GuideContentItem(
        icon: Icons.folder_open_rounded,
        title: l.guideCreateCategoriesTitle,
        description: l.guideCreateCategoriesDescription,
      ),
      _GuideContentItem(
        icon: Icons.link_rounded,
        title: l.guideAddLinksTitle,
        description: l.guideAddLinksDescription,
      ),
      _GuideContentItem(
        icon: Icons.lock_outline_rounded,
        title: l.guideLockCategoriesTitle,
        description: l.guideLockCategoriesDescription,
      ),
      _GuideContentItem(
        icon: Icons.settings_outlined,
        title: l.guideManageSettingsTitle,
        description: l.guideManageSettingsDescription,
      ),
    ];

    return Container(
      decoration: BoxDecoration(gradient: context.screenGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            l.guideTitle,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedGuideSection(
                  animation: _buildSectionAnimation(0.0, 0.22),
                  child: _WelcomeCard(
                    title: l.guideWelcomeTitle,
                    description: l.guideWelcomeDescription,
                  ),
                ),
                SizedBox(height: 18.h),
                ...guideItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final start = 0.18 + (index * 0.14);
                  final end = (start + 0.24).clamp(0.0, 1.0);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _AnimatedGuideSection(
                      animation: _buildSectionAnimation(start, end),
                      child: GuideItem(
                        icon: item.icon,
                        title: item.title,
                        description: item.description,
                      ),
                    ),
                  );
                }),
                SizedBox(height: 6.h),
                _AnimatedGuideSection(
                  animation: _buildSectionAnimation(0.74, 0.92),
                  child: _PreferenceCard(
                    value: _dontShowAgain,
                    label: l.guideDontShowAgain,
                    onChanged: (value) {
                      setState(() => _dontShowAgain = value);
                    },
                  ),
                ),
                SizedBox(height: 18.h),
                _AnimatedGuideSection(
                  animation: _buildSectionAnimation(0.8, 1.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C6BFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      child: Text(
                        l.guideGotIt,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
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

  Animation<double> _buildSectionAnimation(double start, double end) {
    return CurvedAnimation(
      parent: _animationController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }
}

class _GuideContentItem {
  const _GuideContentItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _AnimatedGuideSection extends StatelessWidget {
  const _AnimatedGuideSection({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.86);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7C6BFF).withOpacity(context.isDark ? 0.24 : 0.18),
            cardColor,
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(context.isDark ? 0.08 : 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6BFF).withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24.w,
            top: -18.h,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C6BFF).withOpacity(0.16),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(context.isDark ? 0.1 : 0.62),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                description,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 22.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GuideItem extends StatefulWidget {
  const GuideItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  State<GuideItem> createState() => _GuideItemState();
}

class _GuideItemState extends State<GuideItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.82);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.98 : 1,
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: Colors.white.withOpacity(context.isDark ? 0.06 : 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6BFF).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  widget.icon,
                  color: const Color(0xFF7C6BFF),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: context.textSecondary.withOpacity(0.92),
                        fontSize: 13.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
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

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.8);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white.withOpacity(context.isDark ? 0.06 : 0.18),
        ),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        activeColor: const Color(0xFF7C6BFF),
        title: Text(
          label,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

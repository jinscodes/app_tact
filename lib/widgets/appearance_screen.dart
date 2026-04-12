// ignore_for_file: deprecated_member_use

import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/services/theme_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  ThemeMode _selected = ThemeService.themeMode.value;

  @override
  void initState() {
    super.initState();
    ThemeService.themeMode.addListener(_onThemeChanged);
  }

  void _onThemeChanged() => setState(() {
        _selected = ThemeService.themeMode.value;
      });

  @override
  void dispose() {
    ThemeService.themeMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: context.screenGradient,
      ),
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
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l.appearanceTitle,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.appearanceSubtitle,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                _ThemeOption(
                  mode: ThemeMode.system,
                  icon: Icons.brightness_auto_rounded,
                  label: l.appearanceSystem,
                  selected: _selected == ThemeMode.system,
                  onTap: () => ThemeService.setMode(ThemeMode.system),
                ),
                SizedBox(height: 10.h),
                _ThemeOption(
                  mode: ThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  label: l.appearanceLight,
                  selected: _selected == ThemeMode.light,
                  onTap: () => ThemeService.setMode(ThemeMode.light),
                ),
                SizedBox(height: 10.h),
                _ThemeOption(
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  label: l.appearanceDark,
                  selected: _selected == ThemeMode.dark,
                  onTap: () => ThemeService.setMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final ThemeMode mode;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7C6BFF);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.12) : context.cardSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? accent.withOpacity(0.55) : context.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: accent, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Container(
                width: 22.r,
                height: 22.r,
                decoration: const BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 13.sp,
                  ),
                ),
              )
            else
              Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.textSecondary.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/services/language_service.dart';
import 'package:app_tact/widgets/about_screen.dart';
import 'package:app_tact/widgets/help_support_screen.dart';
import 'package:app_tact/widgets/notifications_screen.dart';
import 'package:app_tact/widgets/privacy_security_screen.dart';
import 'package:app_tact/widgets/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Settings extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  const Settings({super.key, this.onNavigateToProfile});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Rebuild when the app language changes so the value label updates.
    LanguageService.locale.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() => setState(() {});

  @override
  void dispose() {
    LanguageService.locale.removeListener(_onLocaleChanged);
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(l),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(l.sectionPreferences),
                    SizedBox(height: 10.h),
                    _buildPreferencesGroup(l),
                    SizedBox(height: 28.h),
                    _sectionLabel(l.sectionAccount),
                    SizedBox(height: 10.h),
                    _buildAccountGroup(l),
                    SizedBox(height: 28.h),
                    _sectionLabel(l.sectionSupport),
                    SizedBox(height: 10.h),
                    _buildSupportGroup(l),
                    SizedBox(height: 32.h),
                    _buildLogoutButton(),
                    SizedBox(height: 48.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
      child: Center(
        child: Text(
          l.settingsTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
      ),
    );
  }

  // ─── Section label ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
      );

  // ─── Preferences ──────────────────────────────────────────────────────────

  Widget _buildPreferencesGroup(AppLocalizations l) {
    return _SettingGroup(
      children: [
        _SettingRow(
          icon: Icons.notifications_outlined,
          iconColor: const Color(0xFF5E9BFF),
          title: l.rowNotifications,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        _SettingRow(
          icon: Icons.palette_outlined,
          iconColor: const Color(0xFFAA8AFF),
          title: l.rowAppearance,
          onTap: () {},
        ),
        _SettingRow(
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF34C759),
          title: l.rowLanguage,
          valueLabel: LanguageService.current.nativeLabel,
          onTap: _showLanguagePicker,
        ),
      ],
    );
  }

  // ─── Account ──────────────────────────────────────────────────────────────

  Widget _buildAccountGroup(AppLocalizations l) {
    return _SettingGroup(
      children: [
        _SettingRow(
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFFAA8AFF),
          title: l.rowProfile,
          onTap: widget.onNavigateToProfile,
        ),
        _SettingRow(
          icon: Icons.security_rounded,
          iconColor: const Color(0xFFFF9F0A),
          title: l.rowPrivacySecurity,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
          ),
        ),
        _SettingRow(
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFF5E9BFF),
          title: l.rowSubscription,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
          ),
        ),
      ],
    );
  }

  // ─── Support ──────────────────────────────────────────────────────────────

  Widget _buildSupportGroup(AppLocalizations l) {
    return _SettingGroup(
      children: [
        _SettingRow(
          icon: Icons.help_outline_rounded,
          iconColor: const Color(0xFF5E9BFF),
          title: l.rowHelpSupport,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
          ),
        ),
        _SettingRow(
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF34C759),
          title: l.rowAbout,
          valueLabel: l.rowVersionLabel,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
      ],
    );
  }

  // ─── Language picker ───────────────────────────────────────────────────

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      isScrollControlled: true,
      builder: (_) => _LanguagePickerSheet(
        current: LanguageService.current.code,
        onSelect: (code) async {
          await LanguageService.setLanguage(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return _LogoutButton(
      onTap: () async {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets — identical design system to the profile screen
// ─────────────────────────────────────────────────────────────────────────────

/// Grouped card container (iOS inset-grouped style).
class _SettingGroup extends StatelessWidget {
  final List<_SettingRow> children;
  const _SettingGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252535),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List<Widget>.generate(children.length, (i) {
          final isFirst = i == 0;
          final isLast = i == children.length - 1;
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? Radius.circular(14.r) : Radius.zero,
                  bottom: isLast ? Radius.circular(14.r) : Radius.zero,
                ),
                child: children[i],
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 56.w,
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// A single row inside a [_SettingGroup].
class _SettingRow extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  /// Optional right-side label (e.g. "English", "Version 1.0.0").
  final String? valueLabel;

  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.valueLabel,
    this.onTap,
  });

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:
          widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp:
          widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel:
          widget.onTap != null ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed ? Colors.white.withOpacity(0.04) : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            // Icon pill
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 17.sp),
            ),
            SizedBox(width: 14.w),
            // Title
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            // Trailing: value label + chevron
            if (widget.valueLabel != null) ...[
              Text(
                widget.valueLabel!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4.w),
            ],
            Icon(Icons.chevron_right_rounded,
                size: 18.sp, color: Colors.white.withOpacity(0.25)),
          ],
        ),
      ),
    );
  }
}

/// Destructive logout button — outline style, no filled red background.
class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: const Color(0xFFFF453A).withOpacity(0.45),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  size: 18.sp,
                  color: const Color(0xFFFF453A).withOpacity(0.85)),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).logOut,
                style: TextStyle(
                  color: const Color(0xFFFF453A).withOpacity(0.85),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Language picker bottom sheet ────────────────────────────────────────────

class _LanguagePickerSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const _LanguagePickerSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            AppLocalizations.of(context).langPickerTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            AppLocalizations.of(context).langPickerSubtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 24.h),

          // Language options
          ...LanguageService.supported.map((lang) {
            final isSelected = lang.code == current;
            return GestureDetector(
              onTap: () => onSelect(lang.code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7C6BFF).withOpacity(0.15)
                      : const Color(0xFF252535),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF7C6BFF).withOpacity(0.55)
                        : Colors.white.withOpacity(0.06),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lang.flag, style: TextStyle(fontSize: 24.sp)),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.nativeLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            lang.label,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 22.r,
                        height: 22.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C6BFF),
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
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

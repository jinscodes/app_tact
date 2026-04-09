import 'dart:ui';

import 'package:app_tact/colors.dart';
import 'package:app_tact/services/notification_service.dart';
import 'package:app_tact/widgets/links.dart';
import 'package:app_tact/widgets/profiles.dart';
import 'package:app_tact/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  late AnimationController _animationController;
  late Animation<Offset> _outgoingSlideAnimation;
  late Animation<Offset> _incomingSlideAnimation;

  List<Widget> _buildScreens() {
    return [
      const Links(),
      Settings(
        onNavigateToProfile: () => _onItemTapped(2),
      ),
      const Profiles(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _updateAnimations();
    _checkFirstTimeNotification();
  }

  Future<void> _checkFirstTimeNotification() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final notificationService = NotificationService();
    final hasRequested =
        await notificationService.hasRequestedNotificationPermission();

    if (!hasRequested && mounted) {
      _showNotificationPermissionDialog();
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Color(0xFF2E2939),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: AppColors.accentPurple,
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Enable Notifications?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Stay updated with link reminders, weekly digests, and new features.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await NotificationService().setNotificationPreferences(
                          enabled: false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        minimumSize: Size(0, 48.h),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFB93CFF),
                            Color(0xFF4F46E5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () async {
                            Navigator.pop(context);
                            await NotificationService()
                                .setNotificationPreferences(
                              enabled: true,
                            );
                          },
                          child: Center(
                            child: Text(
                              'Turn On',
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimations() {
    final isMovingRight = _selectedIndex > _previousIndex;

    _outgoingSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isMovingRight ? -1.0 : 1.0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _incomingSlideAnimation = Tween<Offset>(
      begin: Offset(isMovingRight ? 1.0 : -1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
      _updateAnimations();
      _animationController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Layer 1: deep base linear gradient ─────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF07041A), // near-black indigo (top)
                Color(0xFF0D0921), // dark navy-purple (mid)
                Color(0xFF1C0E3A), // deep rich violet (bottom)
              ],
              stops: [0.0, 0.42, 1.0],
            ),
          ),
        ),

        // ── Layer 2: top-center violet radial glow ──────────────────────
        Positioned(
          top: -80,
          left: -60,
          right: -60,
          child: IgnorePointer(
            child: Container(
              height: 460,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    Color(0x2B6C5CE7), // ~17 % violet
                    Color(0x006C5CE7),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Layer 3: lower-right lavender accent glow ───────────────────
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 340,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.35, 0.6),
                  radius: 0.75,
                  colors: [
                    Color(0x12A29BFE), // ~7 % lavender
                    Color(0x00A29BFE),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Layer 4: app shell ──────────────────────────────────────────
        Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final screens = _buildScreens();
              return Stack(
                children: [
                  // Outgoing screen
                  if (_animationController.status != AnimationStatus.dismissed)
                    SlideTransition(
                      position: _outgoingSlideAnimation,
                      child: screens[_previousIndex],
                    ),
                  // Incoming screen
                  SlideTransition(
                    position:
                        _animationController.status == AnimationStatus.dismissed
                            ? const AlwaysStoppedAnimation(Offset.zero)
                            : _incomingSlideAnimation,
                    child: screens[_selectedIndex],
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: _GlassTabBar(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
      ),
      ],  // Stack children
    );
  }
}

// ── iOS-style glass tab bar ────────────────────────────────────────────────

class _GlassTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _GlassTabBar({
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.link_rounded, label: 'Links'),
    (icon: Icons.tune_rounded, label: 'Settings'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  static const _activeColor = Color(0xFF7C6BFF);
  static const _inactiveColor = Color(0xFF888888);
  static const _activeBg = Color(0x266C5CE7);   // ~15 % violet pill
  static const _activeGlow = Color(0x556C5CE7); // glow shadow

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: const BoxDecoration(
            // dark translucent purple — rgba(16,6,38, 0.88)
            color: Color(0xE01C0E3A),
            border: Border(
              top: BorderSide(
                color: Color(0x26A29BFE), // rgba(162,155,254, 0.15)
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: 10,
            bottom: bottomPadding > 0 ? bottomPadding : 14,
          ),
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                _TabItem(
                  icon: _items[i].icon,
                  label: _items[i].label,
                  selected: selectedIndex == i,
                  onTap: () => onTap(i),
                  activeColor: _activeColor,
                  inactiveColor: _inactiveColor,
                  activeBg: _activeBg,
                  activeGlow: _activeGlow,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeBg;
  final Color activeGlow;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeBg,
    required this.activeGlow,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with optional glow pill
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: activeGlow,
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

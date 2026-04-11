import 'dart:ui';

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
    // Wait until the user has had a moment to see the app before asking
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final notificationService = NotificationService();
    final hasRequested =
        await notificationService.hasRequestedNotificationPermission();

    if (!hasRequested && mounted) {
      _showNotificationPermissionDialog();
    }
  }

  void _showNotificationPermissionDialog() {
    showModalBottomSheet(
      context: context,
      // Allow swipe-down to dismiss (acts as "Not Now")
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      // Slide-up animation via built-in bottom sheet transition
      barrierColor: Colors.black.withOpacity(0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (ctx) => _NotificationPermissionSheet(
        onAllow: () async {
          Navigator.pop(ctx);
          await NotificationService().setNotificationPreferences(enabled: true);
        },
        onDeny: () async {
          Navigator.pop(ctx);
          await NotificationService()
              .setNotificationPreferences(enabled: false);
        },
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
        // ── Layer 1: shared base gradient (unified across all screens) ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1333), // soft purple-black (top)
                Color(0xFF130E24), // deep violet (mid)
                Color(0xFF0F0B1F), // near-black (bottom)
              ],
              stops: [0.0, 0.45, 1.0],
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
      ], // Stack children
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
  static const _inactiveColor = Color(0xFFA0A0A0);
  static const _activeBg = Color(0x1F7C6BFF); // ~12 % violet pill

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            // neutral dark translucent — rgba(39,39,39, 0.58)
            color: Color(0x94272727),
            border: Border(
              top: BorderSide(
                color: Color(0x1AA29BFE), // rgba(162,155,254, 0.10)
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: 10,
            bottom: bottomPadding > 0 ? bottomPadding + 2 : 16,
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

  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeBg,
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
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notification permission bottom sheet ────────────────────────────────────

class _NotificationPermissionSheet extends StatefulWidget {
  const _NotificationPermissionSheet({
    required this.onAllow,
    required this.onDeny,
  });

  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  State<_NotificationPermissionSheet> createState() =>
      _NotificationPermissionSheetState();
}

class _NotificationPermissionSheetState
    extends State<_NotificationPermissionSheet> {
  bool _allowPressed = false;
  bool _denyPressed = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            // Glassmorphism: very subtle white tint over the blurred background
            color: const Color(0xFF1C1828).withOpacity(0.92),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─ Drag indicator ─
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

              // ─ Icon ─
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  // rgba(124,107,255,0.15)
                  color: const Color(0x267C6BFF),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: const Color(0xFF7C6BFF),
                  size: 26.r,
                ),
              ),
              SizedBox(height: 16.h),

              // ─ Title ─
              Text(
                'Allow Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8.h),

              // ─ Body ─
              Text(
                'Get reminders and updates when they matter.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 14.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),

              // ─ Primary: Allow ─
              GestureDetector(
                onTapDown: (_) => setState(() => _allowPressed = true),
                onTapUp: (_) {
                  setState(() => _allowPressed = false);
                  widget.onAllow();
                },
                onTapCancel: () => setState(() => _allowPressed = false),
                child: AnimatedScale(
                  scale: _allowPressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 80),
                  child: Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      // Flat fill — no gradient, per the spec
                      color: const Color(0xFF7C6BFF),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Allow Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // ─ Secondary: Not Now ─
              GestureDetector(
                onTapDown: (_) => setState(() => _denyPressed = true),
                onTapUp: (_) {
                  setState(() => _denyPressed = false);
                  widget.onDeny();
                },
                onTapCancel: () => setState(() => _denyPressed = false),
                child: AnimatedScale(
                  scale: _denyPressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 80),
                  child: Container(
                    width: double.infinity,
                    height: 50.h,
                    alignment: Alignment.center,
                    child: Text(
                      'Not Now',
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

import 'package:app_tact/colors.dart';
import 'package:app_tact/services/notification_service.dart';
import 'package:app_tact/widgets/links_content.dart';
import 'package:app_tact/widgets/profile_content.dart';
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
      const LinksContent(),
      Settings(
        onNavigateToProfile: () => _onItemTapped(2),
      ),
      const ProfileContent(),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientDarkBlue2, AppColors.gradientPurple],
        ),
      ),
      child: Scaffold(
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Color(0xFF2E2939),
            selectedItemColor: Color(0xFF7B68EE),
            unselectedItemColor: Colors.grey[600],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.link),
                label: 'Links',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

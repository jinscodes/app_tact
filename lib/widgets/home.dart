// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:app_tact/components/logo_and_title.dart';
import 'package:app_tact/components/navigation_box.dart';
import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/widgets/links.dart';
import 'package:app_tact/widgets/notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  void _navigateToLinks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LinksScreen()),
    );
  }

  void _navigateToNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color.fromARGB(255, 23, 30, 63), Color(0xFF2E2939)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 60.h,
                left: 20.w,
                right: 20.w,
                child: LogoAndTitle(
                  title: "Welcome",
                  subtitle: "",
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NavigationBox(
                        title: "Links",
                        subtitle: "Manage your saved links",
                        icon: Icons.link,
                        onTap: () => _navigateToLinks(),
                      ),
                      SizedBox(height: 24.h),
                      NavigationBox(
                        title: "Notes",
                        subtitle: "Create and organize notes",
                        icon: Icons.note_alt,
                        onTap: () => _navigateToNotes(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 40.h,
                left: 20.w,
                right: 20.w,
                child: Center(
                  child: Text(
                    "Click to explore more features",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
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

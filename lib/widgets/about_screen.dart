import 'package:app_tact/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_tact/components/common/about_feature_item.dart';
import 'package:app_tact/components/common/info_row.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientDarkBlue, AppColors.gradientPurple],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'About',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.gradientPurple,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/tact_logo.png',
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Tact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 40.h),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Tact',
                        style: TextStyle(
                          color: AppColors.accentPurple,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Tact is your personal link organization tool that helps you keep track of important URLs, resources, and references. Create categories, organize your links, and access them anytime, anywhere.',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14.sp,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                buildFeatureItem(
                  icon: Icons.folder_outlined,
                  title: 'Organize with Categories',
                  description:
                      'Create custom categories to organize your links',
                ),
                buildFeatureItem(
                  icon: Icons.cloud_sync,
                  title: 'Cloud Sync',
                  description: 'Access your links across all your devices',
                ),
                buildFeatureItem(
                  icon: Icons.lock_outline,
                  title: 'Secure & Private',
                  description: 'Your data is encrypted and protected',
                ),
                buildFeatureItem(
                  icon: Icons.note_outlined,
                  title: 'Notes & Annotations',
                  description: 'Add notes and context to your links',
                ),
                SizedBox(height: 32.h),
                // Additional Info
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.accentPurple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      buildInfoRow('Developer', 'Tact Team'),
                      SizedBox(height: 12.h),
                      buildInfoRow('Platform', 'Flutter'),
                      SizedBox(height: 12.h),
                      buildInfoRow('Release Date', 'November 2025'),
                      SizedBox(height: 12.h),
                      buildInfoRow('Contact', 'support@appstact.com'),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  '© 2025 Tact. All rights reserved.',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

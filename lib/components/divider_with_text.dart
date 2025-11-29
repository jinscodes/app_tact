// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.fontGray.withOpacity(0.8),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  color: AppColors.fontGray,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.fontGray.withOpacity(0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
      ],
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _kFiAccent = Color(0xFF7C6BFF);
const _kFiSurface = Color(0xFF1A1A1A);
const _kFiBorder = Color(0x1FFFFFFF);

Widget buildFeatureItem({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: _kFiSurface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: _kFiBorder, width: 1),
    ),
    child: Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: _kFiAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Icon(icon, color: _kFiAccent, size: 20.sp),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                description,
                style: TextStyle(
                  color: const Color(0xFF8A8A8E),
                  fontSize: 13.sp,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

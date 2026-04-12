// ignore_for_file: deprecated_member_use

import 'package:app_tact/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _kAccent = Color(0xFF7C6BFF);

class CustomSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const CustomSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: context.inputSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.inputBorderColor, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children:
          [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(child: Icon(icon, color: _kAccent, size: 18.sp)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: _kAccent,
              inactiveTrackColor: context.switchTrackOff,
              thumbColor: WidgetStateProperty.all(Colors.white),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}

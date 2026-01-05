import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  bool isDestructive = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 50.h,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive
            ? Colors.red.withOpacity(0.2)
            : const Color(0xFF7B68EE).withOpacity(0.2),
        foregroundColor:
            isDestructive ? Colors.red[400] : const Color(0xFF7B68EE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: isDestructive
                ? Colors.red.withOpacity(0.3)
                : const Color(0xFF7B68EE).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      icon: Icon(icon, size: 20.sp),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

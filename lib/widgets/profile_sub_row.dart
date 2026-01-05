import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildSubRow(String label, String value) {
  return Row(
    children: [
      SizedBox(
        width: 90.w,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13.sp,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

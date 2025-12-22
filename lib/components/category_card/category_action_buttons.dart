import 'package:app_tact/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryActionButtons extends StatelessWidget {
  final VoidCallback onAddLink;
  final VoidCallback onDelete;

  const CategoryActionButtons({
    super.key,
    required this.onAddLink,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onAddLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.softPurple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
          ),
          child: Text('Add Link'),
        ),
        SizedBox(width: 12.w),
        ElevatedButton(
          onPressed: onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.softRed,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
          ),
          child: Text('Delete'),
        ),
      ],
    );
  }
}

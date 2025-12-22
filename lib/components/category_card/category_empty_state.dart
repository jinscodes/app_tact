import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryEmptyState extends StatelessWidget {
  final VoidCallback onAddLink;
  final VoidCallback onDelete;

  const CategoryEmptyState({
    super.key,
    required this.onAddLink,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            color: Colors.grey[500],
            size: 40.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'No links in this category yet',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onAddLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7B68EE),
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
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

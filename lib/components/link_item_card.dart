import 'package:app_tact/models/make_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LinkItemCard extends StatelessWidget {
  final LinkItem link;
  final Function(String) onTap;

  const LinkItemCard({
    super.key,
    required this.link,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(link.url),
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          children: [
            Icon(
              Icons.link,
              color: Color(0xFF7B68EE),
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (link.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      link.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Text(
                    link.url,
                    style: TextStyle(
                      color: Color(0xFF7B68EE),
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (link.isFavorite)
              Icon(
                Icons.favorite,
                color: Colors.red[400],
                size: 16.sp,
              ),
            SizedBox(width: 8.w),
            Icon(
              Icons.open_in_new,
              color: Colors.grey[400],
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_tact/utils/date_utils.dart' as AppDateUtils;
import 'package:app_tact/widgets/profile_sub_row.dart';

Widget buildSubscriptionSection(Map<String, dynamic>? profileData) {
  final plan = (profileData?['subscriptionPlan'] as String?)?.trim();
  final status = (profileData?['subscriptionStatus'] as String?)?.trim();
  final renewalRaw = profileData?['subscriptionRenewal'] ??
      profileData?['subscriptionValidUntil'];

  String renewal = '—';
  if (renewalRaw is Timestamp) {
    renewal = AppDateUtils.DateUtils.formatSimpleDate(renewalRaw);
  } else if (renewalRaw is String && renewalRaw.isNotEmpty) {
    renewal = renewalRaw;
  }

  return Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF7B68EE).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.subscriptions,
                color: const Color(0xFF7B68EE),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              'Subscription',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        buildSubRow('Plan', plan ?? 'Free'),
        SizedBox(height: 8.h),
        buildSubRow('Status', status ?? 'inactive'),
        SizedBox(height: 8.h),
        buildSubRow('Renews', renewal),
      ],
    ),
  );
}

import 'package:app_tact/components/common/about_feature_item.dart';
import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Design tokens ────────────────────────────────────────────────────
const _kAccent = Color(0xFF7C6BFF);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: context.screenGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context).aboutTitle,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 32.h),

                // ── Hero ──────────────────────────────────────────────
                Container(
                  width: 84.r,
                  height: 84.r,
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: _kAccent.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/tact_logo.png',
                      width: 46.w,
                      height: 46.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Tact',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border:
                        Border.all(color: _kAccent.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: _kAccent,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  AppLocalizations.of(context).aboutAppSubtitle,
                  style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14.sp,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 32.h),

                // ── About card ────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: context.cardSurface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: context.borderColor, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              color: _kAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Icon(Icons.info_outline_rounded,
                                  color: _kAccent, size: 14.sp),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            AppLocalizations.of(context).aboutCardTitle,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        AppLocalizations.of(context).aboutCardBody,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 13.sp,
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Section label ─────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      children: [
                        Container(
                          width: 3.w,
                          height: 13.h,
                          decoration: BoxDecoration(
                            color: _kAccent,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(context).aboutSectionFeatures,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                buildFeatureItem(
                  context: context,
                  icon: Icons.folder_outlined,
                  title: AppLocalizations.of(context).aboutFeature1Title,
                  description: AppLocalizations.of(context).aboutFeature1Desc,
                ),
                buildFeatureItem(
                  context: context,
                  icon: Icons.cloud_sync_outlined,
                  title: AppLocalizations.of(context).aboutFeature2Title,
                  description: AppLocalizations.of(context).aboutFeature2Desc,
                ),
                buildFeatureItem(
                  context: context,
                  icon: Icons.lock_outline_rounded,
                  title: AppLocalizations.of(context).aboutFeature3Title,
                  description: AppLocalizations.of(context).aboutFeature3Desc,
                ),
                buildFeatureItem(
                  context: context,
                  icon: Icons.sticky_note_2_outlined,
                  title: AppLocalizations.of(context).aboutFeature4Title,
                  description: AppLocalizations.of(context).aboutFeature4Desc,
                ),

                SizedBox(height: 24.h),

                // ── Info card ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: context.cardSurface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: context.borderColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                          label:
                              AppLocalizations.of(context).aboutInfoDeveloper,
                          value: 'Jay Han'),
                      _Divider(),
                      _InfoRow(
                          label: AppLocalizations.of(context).aboutInfoPlatform,
                          value: 'Flutter'),
                      _Divider(),
                      _InfoRow(
                          label: AppLocalizations.of(context).aboutInfoReleased,
                          value: 'November 2025'),
                      _Divider(),
                      _InfoRow(
                          label: AppLocalizations.of(context).aboutInfoContact,
                          value: 'jayhan0215@gmail.com'),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),
                Text(
                  AppLocalizations.of(context).aboutCopyright,
                  style:
                      TextStyle(color: context.textSecondary, fontSize: 12.sp),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: context.textSecondary, fontSize: 13.sp)),
          Text(value,
              style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: context.borderColor);
}

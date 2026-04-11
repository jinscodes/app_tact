// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/faq_item.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showBugReportDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isInputEmpty = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void updateInputState() {
            setState(() {
              isInputEmpty = titleController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty;
            });
          }

          titleController.addListener(updateInputState);
          descriptionController.addListener(updateInputState);

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 360.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: const Color(0x1FFFFFFF),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4.h),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).helpBugDialogTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      AppLocalizations.of(context).helpBugTitleLabel,
                      style: TextStyle(
                        color: const Color(0xFF8A8A8E),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262626),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0x1FFFFFFF),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0x1FFFFFFF),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF7C6BFF),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      AppLocalizations.of(context).helpDescriptionLabel,
                      style: TextStyle(
                        color: const Color(0xFF8A8A8E),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262626),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0x1FFFFFFF),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0x1FFFFFFF),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF7C6BFF),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF262626),
                              side: const BorderSide(
                                color: Color(0x1FFFFFFF),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              minimumSize: Size(0, 44.h),
                            ),
                            child: Text(
                              AppLocalizations.of(context).helpCancel,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SizedBox(
                            height: 44.h,
                            child: ElevatedButton(
                              onPressed: isInputEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      MessageUtils.showSuccessMessage(
                                        context,
                                        AppLocalizations.of(context)
                                            .helpBugSubmitted,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInputEmpty
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFF7C6BFF),
                                foregroundColor: isInputEmpty
                                    ? const Color(0xFF8A8A8E)
                                    : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).helpSubmit,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFeatureRequestDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isInputEmpty = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void updateInputState() {
            setState(() {
              isInputEmpty = titleController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty;
            });
          }

          titleController.addListener(updateInputState);
          descriptionController.addListener(updateInputState);

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 360.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: const Color(0x1FFFFFFF),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4.h),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).helpFeatureDialogTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      AppLocalizations.of(context).helpFeatureTitleLabel,
                      style: TextStyle(
                        color: const Color(0xFF8A8A8E),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262626),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0x1FFFFFFF),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0x1FFFFFFF),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF7C6BFF),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      AppLocalizations.of(context).helpDescriptionLabel,
                      style: TextStyle(
                        color: const Color(0xFF8A8A8E),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262626),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0x1FFFFFFF),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0x1FFFFFFF),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF7C6BFF),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF262626),
                              side: const BorderSide(
                                color: Color(0x1FFFFFFF),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              minimumSize: Size(0, 44.h),
                            ),
                            child: Text(
                              AppLocalizations.of(context).helpCancel,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SizedBox(
                            height: 44.h,
                            child: ElevatedButton(
                              onPressed: isInputEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      MessageUtils.showSuccessMessage(
                                        context,
                                        AppLocalizations.of(context)
                                            .helpFeatureSubmitted,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInputEmpty
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFF7C6BFF),
                                foregroundColor: isInputEmpty
                                    ? const Color(0xFF8A8A8E)
                                    : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).helpSubmit,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l.helpTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(l.helpSectionContactUs),
                CustomTile(
                  icon: Icons.email_outlined,
                  title: l.helpEmailSupportTitle,
                  subtitle: 'jayhan0215@gmail.com',
                  onTap: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: 'jayhan0215@gmail.com'),
                    );
                    if (context.mounted) {
                      MessageUtils.showSuccessMessage(
                        context,
                        AppLocalizations.of(context).helpEmailCopied,
                      );
                    }
                  },
                ),
                CustomTile(
                  icon: Icons.bug_report_outlined,
                  title: l.helpReportBugTitle,
                  subtitle: l.helpReportBugSubtitle,
                  onTap: () {
                    _showBugReportDialog(context);
                  },
                ),
                SizedBox(height: 24.h),
                SectionTitle(l.helpSectionFAQ),
                FAQItem(
                  question: l.helpFAQ1Q,
                  answer: l.helpFAQ1A,
                ),
                FAQItem(
                  question: l.helpFAQ2Q,
                  answer: l.helpFAQ2A,
                ),
                FAQItem(
                  question: l.helpFAQ3Q,
                  answer: l.helpFAQ3A,
                ),
                FAQItem(
                  question: l.helpFAQ4Q,
                  answer: l.helpFAQ4A,
                ),
                FAQItem(
                  question: l.helpFAQ5Q,
                  answer: l.helpFAQ5A,
                ),
                FAQItem(
                  question: l.helpFAQ6Q,
                  answer: l.helpFAQ6A,
                ),
                SizedBox(height: 24.h),
                SectionTitle(l.helpSectionResources),
                CustomTile(
                  icon: Icons.book_outlined,
                  title: l.helpUserGuideTitle,
                  subtitle: l.helpUserGuideSubtitle,
                  onTap: () {
                    MessageUtils.showSuccessMessage(
                      context,
                      l.helpOpeningUserGuide,
                    );
                  },
                ),
                CustomTile(
                  icon: Icons.video_library_outlined,
                  title: l.helpVideoTutorialsTitle,
                  subtitle: l.helpVideoTutorialsSubtitle,
                  onTap: () {
                    MessageUtils.showSuccessMessage(
                      context,
                      l.helpOpeningVideoTutorials,
                    );
                  },
                ),
                CustomTile(
                  icon: Icons.article_outlined,
                  title: l.helpBlogUpdatesTitle,
                  subtitle: l.helpBlogUpdatesSubtitle,
                  onTap: () {
                    MessageUtils.showSuccessMessage(
                      context,
                      l.helpOpeningBlog,
                    );
                  },
                ),
                SizedBox(height: 24.h),
                SectionTitle(l.helpSectionCommunity),
                CustomTile(
                  icon: Icons.feedback_outlined,
                  title: l.helpFeatureRequestsTitle,
                  subtitle: l.helpFeatureRequestsSubtitle,
                  onTap: () {
                    _showFeatureRequestDialog(context);
                  },
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

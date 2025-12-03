// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/faq_item.dart';
import 'package:app_tact/components/common/section_title.dart';
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
                color: Color.fromARGB(255, 41, 41, 59),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Color(0xFF585967),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        'Report a Bug',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'Bug Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
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
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
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
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(0xFF353442),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              minimumSize: Size(0, 42.h),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 42.h,
                            decoration: BoxDecoration(
                              gradient: isInputEmpty
                                  ? LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.grey.withOpacity(0.5),
                                        Colors.grey.withOpacity(0.5),
                                      ],
                                    )
                                  : LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFB93CFF),
                                        Color(0xFF4F46E5),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8.r),
                                onTap: isInputEmpty
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                        MessageUtils.showSuccessMessage(
                                          context,
                                          'Bug report submitted!',
                                        );
                                      },
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: isInputEmpty
                                          ? Colors.grey[600]
                                          : Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                color: Color.fromARGB(255, 41, 41, 59),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Color(0xFF585967),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        'Feature Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'Feature Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
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
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
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
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(0xFF353442),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              minimumSize: Size(0, 42.h),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 42.h,
                            decoration: BoxDecoration(
                              gradient: isInputEmpty
                                  ? LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.grey.withOpacity(0.5),
                                        Colors.grey.withOpacity(0.5),
                                      ],
                                    )
                                  : LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFB93CFF),
                                        Color(0xFF4F46E5),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8.r),
                                onTap: isInputEmpty
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                        MessageUtils.showSuccessMessage(
                                          context,
                                          'Feature request submitted!',
                                        );
                                      },
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: isInputEmpty
                                          ? Colors.grey[600]
                                          : Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientDarkBlue, AppColors.gradientPurple],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Help & Support',
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
                SectionTitle('Contact Us'),
                CustomTile(
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'jayhan0215@gmail.com',
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: 'jayhan0215@gmail.com'),
                    );
                    if (context.mounted) {
                      MessageUtils.showSuccessMessage(
                        context,
                        'Email copied to clipboard',
                      );
                    }
                  },
                ),
                // CustomTile(
                //   icon: Icons.chat_bubble_outline,
                //   title: 'Live Chat',
                //   subtitle: 'Chat with our support team',
                //   onTap: () {
                //     MessageUtils.showSuccessMessage(
                //       context,
                //       'Live chat coming soon!',
                //     );
                //   },
                // ),
                CustomTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve Tact',
                  onTap: () {
                    _showBugReportDialog(context);
                  },
                ),
                SizedBox(height: 24.h),
                SectionTitle('Frequently Asked Questions'),
                FAQItem(
                  question: 'How do I create a category?',
                  answer:
                      'Tap the + button on the main screen, enter a category name and emoji, then tap Create.',
                ),
                FAQItem(
                  question: 'How do I add links to a category?',
                  answer:
                      'Tap on a category card, then tap the + button to add a new link. Enter the URL and optional title.',
                ),
                FAQItem(
                  question: 'Can I sync my data across devices?',
                  answer:
                      'Yes! Your data is automatically synced across all devices where you\'re signed in with the same account.',
                ),
                FAQItem(
                  question: 'How do I delete a category?',
                  answer:
                      'Long press on a category card, then select the delete option from the menu.',
                ),
                FAQItem(
                  question: 'Is my data secure?',
                  answer:
                      'Yes, all your data is encrypted and stored securely using Firebase. We take your privacy seriously.',
                ),
                FAQItem(
                  question: 'How do I change my password?',
                  answer:
                      'Go to Settings > Privacy & Security > Change Password to update your account password.',
                ),
                SizedBox(height: 24.h),
                SectionTitle('Resources'),
                CustomTile(
                  icon: Icons.book_outlined,
                  title: 'User Guide',
                  subtitle: 'Learn how to use Tact',
                  onTap: () {
                    MessageUtils.showSuccessMessage(
                      context,
                      'Opening user guide...',
                    );
                  },
                ),
                CustomTile(
                  icon: Icons.video_library_outlined,
                  title: 'Video Tutorials',
                  subtitle: 'Watch step-by-step guides',
                  onTap: () {
                    MessageUtils.showSuccessMessage(
                      context,
                      'Opening video tutorials...',
                    );
                  },
                ),
                CustomTile(
                  icon: Icons.article_outlined,
                  title: 'Blog & Updates',
                  subtitle: 'Latest news and tips',
                  onTap: () {
                    MessageUtils.showSuccessMessage(
                      context,
                      'Opening blog...',
                    );
                  },
                ),
                SizedBox(height: 24.h),
                SectionTitle('Community'),
                CustomTile(
                  icon: Icons.feedback_outlined,
                  title: 'Feature Requests',
                  subtitle: 'Suggest new features',
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

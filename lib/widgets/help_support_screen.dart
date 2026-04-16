// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:app_tact/components/common/custom_list_tile.dart';
import 'package:app_tact/components/common/faq_item.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/components/undo_banner.dart';
import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static Future<void> _submitSubmission({
    required BuildContext context,
    required String collectionName,
    required Map<String, dynamic> payload,
    required String failureLogLabel,
    required VoidCallback onSuccess,
    required ValueChanged<bool> setLoading,
  }) async {
    final l = AppLocalizations.of(context);

    setLoading(true);
    try {
      await FirebaseFirestore.instance.collection(collectionName).add(payload);
      debugPrint('$failureLogLabel succeeded.');
      onSuccess();
    } on FirebaseException catch (error) {
      debugPrint('$failureLogLabel failed: ${error.message}');
      if (context.mounted) {
        setLoading(false);
        MessageUtils.showErrorMessage(
          context,
          error.message ?? l.helpSubmitFailed,
        );
      }
    } catch (error) {
      debugPrint('$failureLogLabel failed: $error');
      if (context.mounted) {
        setLoading(false);
        MessageUtils.showErrorMessage(context, l.helpSubmitFailed);
      }
    }
  }

  static Future<void> submitContactSupport({
    required BuildContext context,
    required String message,
    required String email,
    required VoidCallback onSuccess,
    required ValueChanged<bool> setLoading,
  }) async {
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      MessageUtils.showErrorMessage(context, 'Message cannot be empty.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    debugPrint('Support submission current user uid: ${user?.uid}');

    if (user == null) {
      MessageUtils.showErrorMessage(
        context,
        'You must be signed in to send a message.',
      );
      return;
    }

    final payload = <String, dynamic>{
      'email': email.trim(),
      'message': trimmedMessage,
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
      'type': 'support',
    };

    debugPrint('Contact support payload: $payload');

    await _submitSubmission(
      context: context,
      collectionName: 'contact_support_submissions',
      payload: payload,
      failureLogLabel: 'Contact support submission',
      onSuccess: onSuccess,
      setLoading: setLoading,
    );
  }

  static Future<void> submitFeedback({
    required BuildContext context,
    required String category,
    required String message,
    required String email,
    required VoidCallback onSuccess,
    required ValueChanged<bool> setLoading,
  }) async {
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      MessageUtils.showErrorMessage(context, 'Message cannot be empty.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    debugPrint('Feedback current user uid: ${user?.uid}');

    if (user == null) {
      MessageUtils.showErrorMessage(
        context,
        'You must be signed in to send a message.',
      );
      return;
    }

    final payload = <String, dynamic>{
      'category': category,
      'message': trimmedMessage,
      'email': email.trim(),
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
      'type': 'feedback',
    };

    debugPrint('Feedback payload: $payload');

    await _submitSubmission(
      context: context,
      collectionName: 'feedback_submissions',
      payload: payload,
      failureLogLabel: 'Feedback submission',
      onSuccess: onSuccess,
      setLoading: setLoading,
    );
  }

  // ─── Contact Support sheet ────────────────────────────────────────────────

  void _showContactSupportSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    final emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email ?? '',
    );
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SupportSheet(
        title: l.helpContactSheetTitle,
        emailController: emailController,
        messageController: messageController,
        emailLabel: l.helpContactEmailLabel,
        messageLabel: l.helpContactMessageLabel,
        messageHint: l.helpContactMessageHint,
        submitLabel: l.helpFeedbackSend,
        cancelLabel: l.helpCancel,
        onSubmit: () {},
      ),
    );
  }

  // ─── Send Feedback sheet ──────────────────────────────────────────────────

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FeedbackSheet(onSubmit: () {}),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(gradient: context.screenGradient),
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
            l.helpTitle,
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
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(l.helpSectionContactUs),
                CustomTile(
                  icon: Icons.headset_mic_outlined,
                  title: l.helpEmailSupportTitle,
                  subtitle: l.helpEmailSupportSubtitle,
                  onTap: () => _showContactSupportSheet(context),
                ),
                CustomTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: l.helpReportBugTitle,
                  subtitle: l.helpReportBugSubtitle,
                  onTap: () => _showFeedbackSheet(context),
                ),
                SizedBox(height: 24.h),
                SectionTitle(l.helpSectionFAQ),
                FAQItem(question: l.helpFAQ1Q, answer: l.helpFAQ1A),
                FAQItem(question: l.helpFAQ2Q, answer: l.helpFAQ2A),
                FAQItem(question: l.helpFAQ3Q, answer: l.helpFAQ3A),
                FAQItem(question: l.helpFAQ4Q, answer: l.helpFAQ4A),
                FAQItem(question: l.helpFAQ5Q, answer: l.helpFAQ5A),
                FAQItem(question: l.helpFAQ6Q, answer: l.helpFAQ6A),
                SizedBox(height: 24.h),
                SectionTitle(l.helpSectionResources),
                CustomTile(
                  icon: Icons.book_outlined,
                  title: l.helpUserGuideTitle,
                  subtitle: l.helpUserGuideSubtitle,
                  onTap: () {
                    Navigator.pushNamed(context, '/user-guide');
                  },
                ),
                CustomTile(
                  icon: Icons.video_library_outlined,
                  title: l.helpVideoTutorialsTitle,
                  subtitle: l.helpVideoTutorialsSubtitle,
                  onTap: () {
                    MessageUtils.showSuccessMessage(
                        context, l.helpOpeningVideoTutorials);
                  },
                ),
                CustomTile(
                  icon: Icons.article_outlined,
                  title: l.helpBlogUpdatesTitle,
                  subtitle: l.helpBlogUpdatesSubtitle,
                  onTap: () {
                    MessageUtils.showSuccessMessage(context, l.helpOpeningBlog);
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

// ─── Contact Support bottom sheet ────────────────────────────────────────────

class _SupportSheet extends StatefulWidget {
  final String title;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final String emailLabel;
  final String messageLabel;
  final String messageHint;
  final String submitLabel;
  final String cancelLabel;
  final VoidCallback onSubmit;

  const _SupportSheet({
    required this.title,
    required this.emailController,
    required this.messageController,
    required this.emailLabel,
    required this.messageLabel,
    required this.messageHint,
    required this.submitLabel,
    required this.cancelLabel,
    required this.onSubmit,
  });

  @override
  State<_SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends State<_SupportSheet> {
  bool _loading = false;

  bool get _canSubmit =>
      !_loading && widget.messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(() => setState(() {}));
  }

  Future<void> _submit() async {
    await HelpSupportScreen.submitContactSupport(
      context: context,
      message: widget.messageController.text,
      email: widget.emailController.text,
      setLoading: (value) {
        if (mounted) {
          setState(() => _loading = value);
        }
      },
      onSuccess: () {
        if (!mounted) {
          return;
        }
        HapticFeedback.lightImpact();
        showToast(
          context: context,
          message: AppLocalizations.of(context).helpContactSubmitted,
          icon: Icons.check_circle_outline_rounded,
        );
        Navigator.pop(context);
        widget.onSubmit();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border.all(color: context.borderColor, width: 0.8),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                widget.title,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              _FieldLabel(widget.emailLabel, context),
              SizedBox(height: 6.h),
              _StyledField(
                controller: widget.emailController,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                ctx: context,
              ),
              SizedBox(height: 12.h),
              _FieldLabel(widget.messageLabel, context),
              SizedBox(height: 6.h),
              _StyledField(
                controller: widget.messageController,
                hint: widget.messageHint,
                maxLines: 4,
                ctx: context,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _SheetButton(
                      label: widget.cancelLabel,
                      isPrimary: false,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _SheetButton(
                      label: widget.submitLabel,
                      isPrimary: true,
                      enabled: _canSubmit,
                      loading: _loading,
                      onTap: _canSubmit ? _submit : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Send Feedback bottom sheet ───────────────────────────────────────────────

class _FeedbackSheet extends StatefulWidget {
  final VoidCallback onSubmit;
  const _FeedbackSheet({required this.onSubmit});

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _messageController = TextEditingController();
  int _selectedCategory = 0; // 0 = Bug, 1 = Suggestion
  bool _loading = false;

  bool get _canSubmit => !_loading && _messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit(String categoryKey) async {
    await HelpSupportScreen.submitFeedback(
      context: context,
      category: categoryKey,
      message: _messageController.text,
      email: FirebaseAuth.instance.currentUser?.email ?? '',
      setLoading: (value) {
        if (mounted) {
          setState(() => _loading = value);
        }
      },
      onSuccess: () {
        if (!mounted) {
          return;
        }
        HapticFeedback.lightImpact();
        showToast(
          context: context,
          message: AppLocalizations.of(context).helpFeedbackSubmitted,
          icon: Icons.favorite_border_rounded,
        );
        Navigator.pop(context);
        widget.onSubmit();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final categories = [
      l.helpFeedbackCategoryBug,
      l.helpFeedbackCategorySuggestion
    ];
    final categoryKeys = ['bug', 'suggestion'];

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border.all(color: context.borderColor, width: 0.8),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l.helpFeedbackSheetTitle,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 14.h),

              // Category toggle
              Row(
                children: List.generate(categories.length, (i) {
                  final active = _selectedCategory == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(right: 8.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF7C6BFF).withOpacity(0.15)
                            : context.inputSurface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: active
                              ? const Color(0xFF7C6BFF)
                              : context.borderColor,
                          width: active ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        categories[i],
                        style: TextStyle(
                          color: active
                              ? const Color(0xFF7C6BFF)
                              : context.textSecondary,
                          fontSize: 13.sp,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 12.h),

              _FieldLabel(l.helpFeedbackMessageLabel, context),
              SizedBox(height: 6.h),
              _StyledField(
                controller: _messageController,
                hint: l.helpFeedbackMessageHint,
                maxLines: 4,
                ctx: context,
              ),
              SizedBox(height: 8.h),

              // Device info note
              Text(
                l.helpFeedbackDeviceInfo,
                style: TextStyle(
                  color: context.textSecondary.withOpacity(0.6),
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 20.h),

              Row(
                children: [
                  Expanded(
                    child: _SheetButton(
                      label: l.helpCancel,
                      isPrimary: false,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _SheetButton(
                      label: l.helpFeedbackSend,
                      isPrimary: true,
                      enabled: _canSubmit,
                      loading: _loading,
                      onTap: _canSubmit
                          ? () => _submit(categoryKeys[_selectedCategory])
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final BuildContext ctx;
  const _FieldLabel(this.text, this.ctx);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: ctx.textSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final BuildContext ctx;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.ctx,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: ctx.textPrimary, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: ctx.textSecondary.withOpacity(0.4),
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: ctx.inputSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: ctx.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: ctx.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFF7C6BFF), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final bool enabled;
  final bool loading;
  final VoidCallback? onTap;

  const _SheetButton({
    required this.label,
    required this.isPrimary,
    this.enabled = true,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPrimary) {
      return SizedBox(
        height: 44.h,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: context.inputSurface,
            side: BorderSide(color: context.borderColor, width: 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 44.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? const Color(0xFF7C6BFF) : const Color(0xFF2C2C2E),
          foregroundColor: enabled ? Colors.white : const Color(0xFF8A8A8E),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
        child: loading
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

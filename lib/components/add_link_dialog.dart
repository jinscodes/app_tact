// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:app_tact/services/links_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants — Apple HIG values
// ─────────────────────────────────────────────────────────────────────────────
const _kHorizontalPad = 16.0;
const _kFieldRadius = 12.0;
const _kFieldHeight = 50.0;
const _kBtnHeight = 50.0;
const _kBtnRadius = 14.0;
const _kSectionSpacing = 24.0;
const _kItemSpacing = 12.0;
const _kDragHandleW = 36.0;
const _kDragHandleH = 5.0;
const _kSheetBg = Color(0xFF1C1C1C);
const _kSheetHeaderBg = Color(0x0D6C5CE7); // 5 % purple tint on header
const _kFieldBg = Color(0xFF2A2A2A);
const _kSeparator = Color(0xFF333333);
const _kLabelColor = Color(0xFF8E8E93);
const _kAccent = Color(0xFF6C5CE7); // primary gradient start
const _kAccentLight = Color(0xFFA29BFE); // primary gradient end
const _kGlow = Color(0x666C5CE7); // 40 % purple shadow

class AddLinkDialog extends StatefulWidget {
  final String categoryId;
  final LinksService linksService;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const AddLinkDialog({
    super.key,
    required this.categoryId,
    required this.linksService,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<AddLinkDialog> createState() => _AddLinkDialogState();

  static void show(
    BuildContext context, {
    required String categoryId,
    required LinksService linksService,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      enableDrag: true,
      useSafeArea: false,
      builder: (context) => AddLinkDialog(
        categoryId: categoryId,
        linksService: linksService,
        onSuccess: onSuccess,
        onError: onError,
      ),
    );
  }
}

class _AddLinkDialogState extends State<AddLinkDialog> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocus = FocusNode();
  final _urlFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Trigger rebuild on focus change so active field gets highlight
    _titleFocus.addListener(() => setState(() {}));
    _urlFocus.addListener(() => setState(() {}));
    _descriptionFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _urlFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _handleAddLink() async {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();
    if (title.isEmpty || url.isEmpty) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Title and URL are required'),
          backgroundColor: _kFieldBg,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      await widget.linksService.addLinkToCategory(
        widget.categoryId,
        title,
        url,
        _descriptionController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      widget.onError('Error adding link: $e');
    }
  }

  // ── iOS-style field decoration ────────────────────────────────────────────
  InputDecoration _ios({
    required String placeholder,
  }) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: const TextStyle(
        color: _kLabelColor,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: _kFieldBg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kFieldRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kFieldRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kFieldRadius),
        borderSide: const BorderSide(color: _kAccentLight, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kFieldRadius),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardH = mq.viewInsets.bottom;
    final safeBottom = mq.padding.bottom;
    final screenH = mq.size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardH),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: screenH * 0.90,
              ),
              decoration: BoxDecoration(
                color: _kSheetBg.withOpacity(0.97),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag indicator ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Container(
                        width: _kDragHandleW,
                        height: _kDragHandleH,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),

                  // ── Navigation bar (subtle purple tint) ───────────────
                  Container(
                    color: _kSheetHeaderBg,
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Title
                          const Text(
                            'Add New Link',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                            ),
                          ),
                          // Close button — 44×44pt tap target
                          Positioned(
                            right: 4,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: _kLabelColor,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Hair-line separator ───────────────────────────────
                  const Divider(color: _kSeparator, height: 1, thickness: 0.5),

                  // ── Scrollable form ───────────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        _kHorizontalPad,
                        _kSectionSpacing,
                        _kHorizontalPad,
                        _kSectionSpacing,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section: Link Info
                          _SectionLabel('LINK INFO'),
                          const SizedBox(height: 8),

                          // Title
                          SizedBox(
                            height: _kFieldHeight,
                            child: TextField(
                              controller: _titleController,
                              focusNode: _titleFocus,
                              enabled: !_isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_urlFocus),
                              decoration: _ios(placeholder: 'Title'),
                            ),
                          ),
                          const SizedBox(height: _kItemSpacing),

                          // URL
                          SizedBox(
                            height: _kFieldHeight,
                            child: TextField(
                              controller: _urlController,
                              focusNode: _urlFocus,
                              enabled: !_isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                              keyboardType: TextInputType.url,
                              autocorrect: false,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_descriptionFocus),
                              decoration: _ios(placeholder: 'URL'),
                            ),
                          ),

                          const SizedBox(height: _kSectionSpacing),

                          // Section: Description
                          _SectionLabel('DESCRIPTION'),
                          const SizedBox(height: 8),

                          TextField(
                            controller: _descriptionController,
                            focusNode: _descriptionFocus,
                            enabled: !_isLoading,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                            maxLines: null,
                            minLines: 4,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                            decoration: _ios(
                              placeholder: 'Add notes (optional)',
                            ).copyWith(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Sticky CTA ────────────────────────────────────────
                  Container(
                    color: _kSheetBg,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(
                            color: _kSeparator, height: 1, thickness: 0.5),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            _kHorizontalPad,
                            12,
                            _kHorizontalPad,
                            keyboardH > 0
                                ? 12
                                : (safeBottom > 0 ? safeBottom + 8 : 28),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kAccent, _kAccentLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(_kBtnRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: _kGlow,
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: _kBtnHeight,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleAddLink,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(_kBtnRadius),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Add Link',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section header label (iOS grouped style) ──────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _kLabelColor,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.06,
      ),
    );
  }
}

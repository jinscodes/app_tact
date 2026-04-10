// ignore_for_file: deprecated_member_use

import 'package:app_tact/components/sheet_theme.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    showAppSheet(
      context: context,
      child: AddLinkDialog(
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
          backgroundColor: kInputBg,
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

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Add New Link',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          kSheetHPad,
          kSheetSectionSpacing,
          kSheetHPad,
          8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section: Link Info ─────────────────────────────────────
            const SheetSectionLabel('LINK INFO'),
            const SizedBox(height: 8),

            // Title
            SizedBox(
              height: kSheetFieldHeight,
              child: TextField(
                controller: _titleController,
                focusNode: _titleFocus,
                enabled: !_isLoading,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_urlFocus),
                decoration: sheetInputDecoration(placeholder: 'Title'),
              ),
            ),
            const SizedBox(height: kSheetItemSpacing),

            // URL
            SizedBox(
              height: kSheetFieldHeight,
              child: TextField(
                controller: _urlController,
                focusNode: _urlFocus,
                enabled: !_isLoading,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_descriptionFocus),
                decoration: sheetInputDecoration(placeholder: 'URL'),
              ),
            ),

            const SizedBox(height: kSheetSectionSpacing),

            // ── Section: Description ───────────────────────────────────
            const SheetSectionLabel('DESCRIPTION'),
            const SizedBox(height: 8),

            TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              enabled: !_isLoading,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
              maxLines: null,
              minLines: 4,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              decoration: sheetInputDecoration(
                placeholder: 'Add notes (optional)',
              ).copyWith(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: kSheetSectionSpacing),
          ],
        ),
      ),
      footer: SheetFooter(
        child: SheetPrimaryButton(
          label: 'Add Link',
          onTap: _handleAddLink,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}

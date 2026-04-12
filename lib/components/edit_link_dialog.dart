// ignore_for_file: deprecated_member_use

import 'package:app_tact/components/sheet_theme.dart';
import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EditLinkDialog extends StatefulWidget {
  final LinkItem link;
  final LinksService linksService;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const EditLinkDialog({
    super.key,
    required this.link,
    required this.linksService,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<EditLinkDialog> createState() => _EditLinkDialogState();

  static void show(
    BuildContext context, {
    required LinkItem link,
    required LinksService linksService,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    showAppSheet(
      context: context,
      child: EditLinkDialog(
        link: link,
        linksService: linksService,
        onSuccess: onSuccess,
        onError: onError,
      ),
    );
  }
}

class _EditLinkDialogState extends State<EditLinkDialog> {
  late final TextEditingController titleController;
  late final TextEditingController urlController;
  late final TextEditingController descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.link.title);
    urlController = TextEditingController(text: widget.link.url);
    descriptionController =
        TextEditingController(text: widget.link.description);
  }

  Future<void> _handleEditLink() async {
    if (titleController.text.trim().isEmpty ||
        urlController.text.trim().isEmpty) {
      widget.onError('Title and URL are required');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.linksService.updateLinkItem(
        widget.link.categoryId,
        widget.link.id,
        title: titleController.text.trim(),
        url: urlController.text.trim(),
        description: descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        widget.onError('Error updating link: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    urlController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Shared field decoration
  InputDecoration _field(BuildContext context, String label) =>
      sheetInputDecoration(context: context, placeholder: label);

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Edit Link',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          kSheetHPad,
          kSheetSectionSpacing,
          kSheetHPad,
          kSheetSectionSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title ─────────────────────────────────────────────────
            const SheetSectionLabel('TITLE'),
            const SizedBox(height: 8),
            SizedBox(
              height: kSheetFieldHeight,
              child: TextField(
                controller: titleController,
                enabled: !_isLoading,
                style: TextStyle(
                  color: context.sheetText,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                textInputAction: TextInputAction.next,
                decoration: _field(context, 'Title'),
              ),
            ),

            const SizedBox(height: kSheetSectionSpacing),

            // ── URL ────────────────────────────────────────────────────
            const SheetSectionLabel('URL'),
            const SizedBox(height: 8),
            SizedBox(
              height: kSheetFieldHeight,
              child: TextField(
                controller: urlController,
                enabled: !_isLoading,
                style: TextStyle(
                  color: context.sheetText,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: _field(context, 'URL'),
              ),
            ),

            const SizedBox(height: kSheetSectionSpacing),

            // ── Description ───────────────────────────────────────────
            const SheetSectionLabel('DESCRIPTION'),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              enabled: !_isLoading,
              style: TextStyle(
                color: context.sheetText,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: _field(context, 'Description (optional)').copyWith(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetPrimaryButton(
              label: 'Save Changes',
              onTap: _handleEditLink,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 10),
            SheetSecondaryButton(
              label: 'Cancel',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

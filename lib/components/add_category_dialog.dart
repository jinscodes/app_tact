// ignore_for_file: deprecated_member_use

import 'package:app_tact/components/sheet_theme.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(String categoryName) onCategoryAdded;

  const AddCategoryDialog({
    super.key,
    required this.onCategoryAdded,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();

  static Future<void> show(
    BuildContext context, {
    required Function(String categoryName) onCategoryAdded,
  }) {
    return showAppSheet(
      context: context,
      child: AddCategoryDialog(
        onCategoryAdded: onCategoryAdded,
      ),
    );
  }
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _categoryController = TextEditingController();
  final LinksService _linksService = LinksService();
  bool _isLoading = false;
  bool _isInputEmpty = true;

  @override
  void initState() {
    super.initState();
    _categoryController.addListener(_updateInputState);
  }

  void _updateInputState() {
    setState(() {
      _isInputEmpty = _categoryController.text.trim().isEmpty;
    });
  }

  @override
  void dispose() {
    _categoryController.removeListener(_updateInputState);
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'New Category',
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
            const SheetSectionLabel('CATEGORY NAME'),
            const SizedBox(height: 8),
            SizedBox(
              height: kSheetFieldHeight,
              child: TextField(
                controller: _categoryController,
                autofocus: true,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                decoration:
                    sheetInputDecoration(placeholder: 'e.g. Work, Personal…'),
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
              label: 'Add Category',
              onTap: _handleAddCategory,
              isLoading: _isLoading,
              enabled: !_isInputEmpty,
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

  Future<void> _handleAddCategory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categoryName = _categoryController.text.trim();

      // Check if user is authenticated
      if (!_linksService.isUserAuthenticated) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      print(
          'Creating category: $categoryName for user: ${_linksService.currentUserId}');

      // Create category in Firebase using LinksService
      await _linksService.createCategoryWithCollection(categoryName);

      print('Category created successfully');

      // Call the callback to notify parent widget
      widget.onCategoryAdded(categoryName);

      // Close the dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error creating category: $e');
      // Show error message
      if (mounted) {
        MessageUtils.showErrorMessage(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

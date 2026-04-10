import 'package:app_tact/components/sheet_theme.dart';
import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:flutter/material.dart';

class DeleteCategoryDialog extends StatefulWidget {
  final Category category;
  final LinksService linksService;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const DeleteCategoryDialog({
    super.key,
    required this.category,
    required this.linksService,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<DeleteCategoryDialog> createState() => _DeleteCategoryDialogState();

  static void show(
    BuildContext context, {
    required Category category,
    required LinksService linksService,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    showAppSheet(
      context: context,
      child: DeleteCategoryDialog(
        category: category,
        linksService: linksService,
        onSuccess: onSuccess,
        onError: onError,
      ),
    );
  }
}

class _DeleteCategoryDialogState extends State<DeleteCategoryDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Delete Category',
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
            // Warning icon
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A3030).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF7A3030),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Primary message
            Center(
              child: Text(
                'Delete \"${widget.category.name}\"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Body text
            Center(
              child: Text(
                'This will permanently delete all ${widget.category.linkCount} '
                'link${widget.category.linkCount == 1 ? '' : 's'} in this '
                'category. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 14,
                  height: 1.5,
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
            SheetSecondaryButton(
              label: 'Delete Category',
              isDestructive: true,
              onTap: _isLoading ? null : _handleDelete,
            ),
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            SheetSecondaryButton(
              label: 'Cancel',
              onTap: _isLoading ? null : () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.linksService.deleteCategory(widget.category.id);
      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      widget.onError('Error deleting category: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    showDialog(
      context: context,
      builder: (context) => DeleteCategoryDialog(
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
    return AlertDialog(
      backgroundColor: Color(0xFF2E2939),
      title: Text(
        'Delete Category',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete "${widget.category.name}"?',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            'This will also delete all ${widget.category.linkCount} links in this category.',
            style: TextStyle(color: Colors.red[300], fontSize: 12.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'This action cannot be undone.',
            style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Delete'),
        ),
      ],
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

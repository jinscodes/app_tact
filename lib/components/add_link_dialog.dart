import 'package:app_tact/services/links_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    showDialog(
      context: context,
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
  final titleController = TextEditingController();
  final urlController = TextEditingController();
  final descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    urlController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF2E2939),
      title: Text(
        'Add Link',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            enabled: !_isLoading,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF7B68EE)),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: urlController,
            enabled: !_isLoading,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'URL',
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF7B68EE)),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: descriptionController,
            enabled: !_isLoading,
            style: TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF7B68EE)),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAddLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF7B68EE),
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
              : Text('Add'),
        ),
      ],
    );
  }

  Future<void> _handleAddLink() async {
    if (titleController.text.trim().isEmpty ||
        urlController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.linksService.addLinkToCategory(
        widget.categoryId,
        titleController.text.trim(),
        urlController.text.trim(),
        descriptionController.text.trim(),
      );
      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      widget.onError('Error adding link: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

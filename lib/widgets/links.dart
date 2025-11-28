import 'package:app_tact/components/add_category_dialog.dart';
import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  final LinksService _linksService = LinksService();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color.fromARGB(255, 23, 30, 63), Color(0xFF2E2939)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Links',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // Categories and Links List
                Expanded(
                  child: StreamBuilder<List<Category>>(
                    stream: _linksService.getCategoriesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[400],
                                size: 80.sp,
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'Error loading categories',
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final categories = snapshot.data ?? [];

                      if (categories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.link_off,
                                color: Colors.grey[400],
                                size: 80.sp,
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'No categories yet',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Start by creating your first category',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _buildCategoryCard(category);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            AddCategoryDialog.show(
              context,
              onCategoryAdded: (categoryName) {
                _handleCategoryAdded(categoryName);
              },
            );
          },
          backgroundColor: Color(0xFF7B68EE),
          foregroundColor: Colors.white,
          icon: Icon(Icons.add),
          label: Text('Add Category'),
        ),
      ),
    );
  }

  void _handleCategoryAdded(String categoryName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Category "$categoryName" added successfully!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16.w),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Color(0xFF7B68EE).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.folder_outlined,
            color: Color(0xFF7B68EE),
            size: 24.sp,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${category.linkCount} links • Created ${_formatDate(category.createdAt)}',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12.sp,
          ),
        ),
        children: [
          StreamBuilder<List<LinkItem>>(
            stream: _linksService.getLinksByCategoryStream(category.id),
            builder: (context, linkSnapshot) {
              if (linkSnapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.all(20.h),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final links = linkSnapshot.data ?? [];

              if (links.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(20.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.link_off,
                        color: Colors.grey[500],
                        size: 40.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No links in this category yet',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: () => _showAddLinkDialog(category.id),
                        icon: Icon(Icons.add, size: 16.sp),
                        label: Text('Add Link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B68EE),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  ...links.map((link) => _buildLinkItem(link)),
                  SizedBox(height: 8.h),
                  ElevatedButton.icon(
                    onPressed: () => _showAddLinkDialog(category.id),
                    icon: Icon(Icons.add, size: 16.sp),
                    label: Text('Add Link'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7B68EE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(LinkItem link) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _launchURL(link.url),
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          children: [
            Icon(
              Icons.link,
              color: Color(0xFF7B68EE),
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (link.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      link.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Text(
                    link.url,
                    style: TextStyle(
                      color: Color(0xFF7B68EE),
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (link.isFavorite)
              Icon(
                Icons.favorite,
                color: Colors.red[400],
                size: 16.sp,
              ),
            SizedBox(width: 8.w),
            Icon(
              Icons.open_in_new,
              color: Colors.grey[400],
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      // For now, just show the URL in a dialog
      // TODO: Add url_launcher dependency for actual URL opening
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF2E2939),
          title: Text('Open Link', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('URL:', style: TextStyle(color: Colors.grey[400])),
              SizedBox(height: 8.h),
              SelectableText(
                url,
                style: TextStyle(color: Color(0xFF7B68EE)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Colors.grey[400])),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  void _showAddLinkDialog(String categoryId) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: urlController,
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
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: descriptionController,
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
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty &&
                  urlController.text.trim().isNotEmpty) {
                try {
                  await _linksService.addLinkToCategory(
                    categoryId,
                    titleController.text.trim(),
                    urlController.text.trim(),
                    descriptionController.text.trim(),
                  );
                  Navigator.pop(context);
                  _showSuccessMessage('Link added successfully!');
                } catch (e) {
                  _showErrorMessage('Error adding link: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7B68EE),
            ),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

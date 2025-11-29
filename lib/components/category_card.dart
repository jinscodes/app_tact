// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/add_link_dialog.dart';
import 'package:app_tact/components/delete_category_dialog.dart';
import 'package:app_tact/components/link_item_card.dart';
import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:app_tact/utils/date_utils.dart' as AppDateUtils;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final LinksService linksService;
  final Function(String) onLinkTap;
  final Function(String) onSuccess;
  final Function(String) onError;

  const CategoryCard({
    super.key,
    required this.category,
    required this.linksService,
    required this.onLinkTap,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
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
          '${category.linkCount} links • Created ${AppDateUtils.DateUtils.formatDate(category.createdAt)}',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12.sp,
          ),
        ),
        children: [
          StreamBuilder<List<LinkItem>>(
            stream: linksService.getLinksByCategoryStream(category.id),
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
                return _buildEmptyState(context);
              }

              return _buildLinksState(context, links);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildLinksState(BuildContext context, List<LinkItem> links) {
    return Column(
      children: [
        ...links.map((link) => LinkItemCard(
              link: link,
              onTap: onLinkTap,
              onEdit: () => _showEditLinkDialog(context, link),
              onDelete: () => _showDeleteLinkDialog(context, link),
            )),
        SizedBox(height: 8.h),
        _buildActionButtons(context),
        SizedBox(height: 16.h),
      ],
    );
  }

  void _showEditLinkDialog(BuildContext context, LinkItem link) {
    onError('Edit link feature coming soon!');
  }

  void _showDeleteLinkDialog(BuildContext context, LinkItem link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2E2939),
        title: Text(
          'Delete Link',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${link.title}"?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await linksService.deleteLinkItem(link.categoryId, link.id);
              } catch (e) {
                onError('Error deleting link: $e');
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _showAddLinkDialog(context, category.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.softPurple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
          ),
          child: Text('Add Link'),
        ),
        SizedBox(width: 12.w),
        ElevatedButton(
          onPressed: () => _showDeleteCategoryDialog(context, category),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.softRed,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
          ),
          child: Text('Delete'),
        ),
      ],
    );
  }

  void _showAddLinkDialog(BuildContext context, String categoryId) {
    AddLinkDialog.show(
      context,
      categoryId: categoryId,
      linksService: linksService,
      onSuccess: () => onSuccess('Link added successfully!'),
      onError: onError,
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, Category category) {
    DeleteCategoryDialog.show(
      context,
      category: category,
      linksService: linksService,
      onSuccess: () {},
      onError: onError,
    );
  }
}

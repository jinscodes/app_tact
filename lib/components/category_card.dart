// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/add_link_dialog.dart';
import 'package:app_tact/components/delete_category_dialog.dart';
import 'package:app_tact/components/edit_link_dialog.dart';
import 'package:app_tact/components/link_item_card.dart';
import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:app_tact/utils/date_utils.dart' as AppDateUtils;
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';

class CategoryCard extends StatefulWidget {
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
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late bool _isLocked;

  @override
  void initState() {
    super.initState();
    _isLocked = widget.category.isLocked;
  }

  Future<void> _handleLockToggle() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        if (mounted) {
          MessageUtils.showErrorMessage(
            context,
            'Biometric authentication is not available on this device',
          );
        }
        return;
      }

      bool authenticated = await _localAuth.authenticate(
        localizedReason: _isLocked
            ? 'Authenticate to unlock category'
            : 'Authenticate to lock category',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && mounted) {
        final newLockState = !_isLocked;

        await Future.delayed(const Duration(milliseconds: 1200));

        if (!mounted) return;

        MessageUtils.showSuccessAnimation(context,
            message: newLockState ? 'Category Locked!' : 'Category Unlocked!');

        await widget.linksService.updateCategoryLockStatus(
          widget.category.id,
          newLockState,
        );

        setState(() {
          _isLocked = newLockState;
        });
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showErrorMessage(
          context,
          'Failed to authenticate: ${e.toString()}',
        );
      }
    }
  }

  void _showAddLinkDialog(BuildContext context, String categoryId) {
    AddLinkDialog.show(
      context,
      categoryId: categoryId,
      linksService: widget.linksService,
      onSuccess: () =>
          MessageUtils.showSuccessAnimation(context, message: 'Link Added!'),
      onError: widget.onError,
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, Category category) {
    DeleteCategoryDialog.show(
      context,
      category: category,
      linksService: widget.linksService,
      onSuccess: () {},
      onError: widget.onError,
    );
  }

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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.symmetric(horizontal: 16.w),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          trailing: InkWell(
            onTap: _handleLockToggle,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                _isLocked ? Icons.lock : Icons.lock_outline,
                color: _isLocked ? Colors.red : Colors.grey[400],
                size: 20.sp,
              ),
            ),
          ),
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
            widget.category.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${widget.category.linkCount} links • Created ${AppDateUtils.DateUtils.formatDate(widget.category.createdAt)}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.sp,
            ),
          ),
          children: [
            StreamBuilder<List<LinkItem>>(
              stream: widget.linksService
                  .getLinksByCategoryStream(widget.category.id),
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
    Widget content = Column(
      children: [
        ...links.map((link) => LinkItemCard(
              link: link,
              onTap: widget.onLinkTap,
              onEdit: () => _showEditLinkDialog(context, link),
              onDelete: () => _showDeleteLinkDialog(context, link),
            )),
        SizedBox(height: 8.h),
        _buildActionButtons(context),
        SizedBox(height: 16.h),
      ],
    );

    if (_isLocked) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: content,
      );
    }

    return content;
  }

  void _showEditLinkDialog(BuildContext context, LinkItem link) {
    EditLinkDialog.show(
      context,
      link: link,
      linksService: widget.linksService,
      onSuccess: () {},
      onError: widget.onError,
    );
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
                await widget.linksService
                    .deleteLinkItem(link.categoryId, link.id);
              } catch (e) {
                widget.onError('Error deleting link: $e');
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
          onPressed: () => _showAddLinkDialog(context, widget.category.id),
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
          onPressed: () => _showDeleteCategoryDialog(context, widget.category),
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
}

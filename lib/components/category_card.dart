// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/components/add_link_dialog.dart';
import 'package:app_tact/components/category_card/category_action_buttons.dart';
import 'package:app_tact/components/category_card/category_empty_state.dart';
import 'package:app_tact/components/category_card/category_lock_handler.dart';
import 'package:app_tact/components/category_card/category_locked_overlay.dart';
import 'package:app_tact/components/delete_category_dialog.dart';
import 'package:app_tact/components/edit_link_dialog.dart';
import 'package:app_tact/components/link_item_card.dart';
import 'package:app_tact/components/undo_banner.dart';
import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:app_tact/utils/date_utils.dart' as AppDateUtils;
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final CategoryLockHandler _lockHandler = CategoryLockHandler();
  late bool _isLocked;

  @override
  void initState() {
    super.initState();
    _isLocked = widget.category.isLocked;
  }

  Future<void> _handleLockToggle() async {
    final success = await _lockHandler.toggleLock(
      context: context,
      currentLockState: _isLocked,
      onLockChanged: (newState) async {
        await widget.linksService.updateCategoryLockStatus(
          widget.category.id,
          newState,
        );
      },
    );

    if (success && mounted) {
      setState(() {
        _isLocked = !_isLocked;
      });
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

  void _showEditLinkDialog(BuildContext context, LinkItem link) {
    EditLinkDialog.show(
      context,
      link: link,
      linksService: widget.linksService,
      onSuccess: () {},
      onError: widget.onError,
    );
  }

  Future<void> _deleteLinkWithUndo(BuildContext context, LinkItem link) async {
    try {
      await widget.linksService.deleteLinkItem(link.categoryId, link.id);
    } catch (e) {
      widget.onError('Error deleting link: $e');
      return;
    }

    if (!context.mounted) return;

    showUndoBanner(
      context: context,
      message: 'Link deleted',
      onUndo: () async {
        try {
          await widget.linksService.restoreLinkItem(link);
        } catch (e) {
          widget.onError('Error restoring link: $e');
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CategoryEmptyState(
      onAddLink: () => _showAddLinkDialog(context, widget.category.id),
      onDelete: () => _showDeleteCategoryDialog(context, widget.category),
    );
  }

  Widget _buildLinksState(BuildContext context, List<LinkItem> links) {
    Widget content = Column(
      children: [
        ...links.map((link) => LinkItemCard(
              key: ValueKey(link.id),
              link: link,
              onTap: widget.onLinkTap,
              onEdit: () => _showEditLinkDialog(context, link),
              onDelete: () => _deleteLinkWithUndo(context, link),
            )),
        SizedBox(height: 8.h),
        CategoryActionButtons(
          onAddLink: () => _showAddLinkDialog(context, widget.category.id),
          onDelete: () => _showDeleteCategoryDialog(context, widget.category),
        ),
        SizedBox(height: 16.h),
      ],
    );

    if (_isLocked) {
      return CategoryLockedOverlay(child: content);
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                context.isDark ? AppColors.cardShadow : const Color(0x14000000),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
          iconColor: context.textPrimary,
          collapsedIconColor: context.textPrimary,
          trailing: IconButton(
            onPressed: _handleLockToggle,
            icon: Icon(
              _isLocked ? Icons.lock : Icons.lock_outline,
              color: _isLocked ? Colors.red : Colors.grey[400],
              size: 20.sp,
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
              color: context.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${widget.category.linkCount} links • Created ${AppDateUtils.DateUtils.formatDate(widget.category.createdAt)}',
            style: TextStyle(
              color: context.textSecondary,
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
                        color: context.textPrimary,
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
}

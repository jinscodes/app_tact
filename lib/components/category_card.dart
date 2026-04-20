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
  final bool isTemporarilyUnlocked;
  final VoidCallback? onTemporarilyUnlock;

  CategoryCard({
    super.key,
    required this.category,
    required this.linksService,
    required this.onLinkTap,
    required this.onSuccess,
    required this.onError,
    this.isTemporarilyUnlocked = false,
    this.onTemporarilyUnlock,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final CategoryLockHandler _lockHandler = CategoryLockHandler();
  final ExpansionTileController _tileController = ExpansionTileController();
  bool _isAuthenticating = false;
  bool? _lockStateOverride;

  @override
  void initState() {
    super.initState();
    // If this card is mounted while already temporarily unlocked, auto-expand.
    if (widget.isTemporarilyUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tileController.expand();
      });
    }
  }

  /// True when the category is locked in Firestore (with optimistic override).
  bool get _isLocked => _lockStateOverride ?? widget.category.isLocked;

  /// True when the user can interact with the category content.
  bool get _canAccess => !_isLocked || widget.isTemporarilyUnlocked;

  /// Lock icon tap → permanent unlock / lock (persists to Firestore).
  Future<void> _handleCategoryLockTap(BuildContext context) async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final isLocked = _isLocked;
      final didAuthenticate = await _lockHandler.authenticateForLockChange(
        context: context,
        currentLockState: isLocked,
      );

      if (!didAuthenticate) return;

      if (isLocked) {
        // Permanently unlock — clear temp flag too.
        await _unlockCategory(widget.category, context);
      } else {
        await _lockCategory(widget.category, context);
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  /// Overlay tap → temporary unlock (local state only, no Firestore update).
  Future<void> _handleTemporaryUnlock(BuildContext context) async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    final didAuthenticate =
        await _lockHandler.authenticateForTemporaryAccess(context: context);

    if (!mounted) return;

    if (didAuthenticate) {
      widget.onTemporarilyUnlock?.call();
      setState(() => _isAuthenticating = false);
    } else {
      setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _unlockCategory(Category category, BuildContext context) async {
    debugPrint('Unlocking category: ${category.id}');

    if (mounted) {
      setState(() => _lockStateOverride = false);
    }

    try {
      await widget.linksService.updateCategoryLockStatus(category.id, false);
      debugPrint('Firestore unlock update success');
      if (!mounted) return;
      showToast(
        context: context,
        message: 'Category unlocked',
        icon: Icons.lock_open_outlined,
      );
    } catch (error) {
      debugPrint('Firestore unlock update failed: $error');
      if (!mounted) return;
      setState(() => _lockStateOverride = null);
      widget.onError('Failed to unlock category. Please try again.');
    }
  }

  Future<void> _lockCategory(Category category, BuildContext context) async {
    debugPrint('Locking category: ${category.id}');

    if (mounted) {
      setState(() => _lockStateOverride = true);
    }

    try {
      await widget.linksService.updateCategoryLockStatus(category.id, true);
      debugPrint('Firestore lock update success');
      if (!mounted) return;
      showToast(
        context: context,
        message: 'Category locked',
        icon: Icons.lock_outline_rounded,
      );
    } catch (error) {
      debugPrint('Firestore lock update failed: $error');
      if (!mounted) return;
      setState(() => _lockStateOverride = null);
      widget.onError('Failed to update category lock. Please try again.');
    }
  }

  @override
  void didUpdateWidget(covariant CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _isAuthenticating = false;
      _lockStateOverride = null;
      return;
    }

    // Auto-expand when temporary unlock is granted.
    if (!oldWidget.isTemporarilyUnlocked && widget.isTemporarilyUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tileController.expand();
      });
    }

    if (_lockStateOverride != null &&
        widget.category.isLocked == _lockStateOverride) {
      _lockStateOverride = null;
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

  Widget _buildLockIcon(bool isLocked) {
    // Always show red closed lock when locked in DB, even if temporarily unlocked.
    if (isLocked) {
      return Icon(
        Icons.lock_rounded,
        key: const ValueKey('locked'),
        color: Colors.red,
        size: 20.sp,
      );
    }
    return Icon(
      Icons.lock_open_outlined,
      key: const ValueKey('unlocked'),
      color: Colors.grey[400],
      size: 20.sp,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CategoryEmptyState(
      onAddLink: () => _showAddLinkDialog(context, widget.category.id),
      onDelete: () => _showDeleteCategoryDialog(context, widget.category),
    );
  }

  Widget _buildLinksState(BuildContext context, List<LinkItem> links) {
    // When temporarily unlocked, show links read-only (no add/delete/edit).
    final isTemporary = _isLocked && widget.isTemporarilyUnlocked;
    Widget content = Column(
      children: [
        ...links.map((link) => LinkItemCard(
              key: ValueKey(link.id),
              link: link,
              onTap: widget.onLinkTap,
              onEdit:
                  isTemporary ? null : () => _showEditLinkDialog(context, link),
              onDelete:
                  isTemporary ? null : () => _deleteLinkWithUndo(context, link),
            )),
        SizedBox(height: 8.h),
        if (!isTemporary)
          CategoryActionButtons(
            onAddLink: () => _showAddLinkDialog(context, widget.category.id),
            onDelete: () => _showDeleteCategoryDialog(context, widget.category),
          ),
        SizedBox(height: 16.h),
      ],
    );

    if (!_canAccess) {
      return CategoryLockedOverlay(
        onTap: _isAuthenticating ? null : () => _handleTemporaryUnlock(context),
        isAuthenticating: _isAuthenticating,
        child: content,
      );
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
          key: PageStorageKey(widget.category.id),
          controller: _tileController,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.symmetric(horizontal: 16.w),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: context.textPrimary,
          collapsedIconColor: context.textPrimary,
          trailing: IconButton(
            onPressed: _isAuthenticating
                ? null
                : () => _handleCategoryLockTap(context),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: _isAuthenticating
                  ? SizedBox(
                      key: const ValueKey('auth-loading'),
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.textSecondary,
                        ),
                      ),
                    )
                  : _buildLockIcon(_isLocked),
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

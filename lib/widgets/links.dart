import 'package:app_tact/components/add_category_dialog.dart';
import 'package:app_tact/components/category_card.dart';
import 'package:app_tact/components/sheet_theme.dart';
import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Links extends StatefulWidget {
  const Links({super.key});

  @override
  State<Links> createState() => _LinksState();
}

class _LinksState extends State<Links> {
  final LinksService _linksService = LinksService();

  Future<void> _launchURL(String url) async {
    try {
      showAppSheet(
        context: context,
        child: AppSheetScaffold(
          title: 'Open Link',
          body: Padding(
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
                const SheetSectionLabel('URL'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(kSheetFieldRadius),
                    border: Border.all(color: kInputBorder, width: 1),
                  ),
                  child: SelectableText(
                    url,
                    style: const TextStyle(
                      color: kAccentEnd,
                      fontSize: 14,
                      height: 1.4,
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
                  label: 'Copy URL',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: url));
                    Navigator.pop(context);
                    MessageUtils.showSuccessMessage(
                        context, 'URL copied to clipboard');
                  },
                ),
                const SizedBox(height: 10),
                SheetSecondaryButton(
                  label: 'Close',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      MessageUtils.showErrorMessage(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                        return CategoryCard(
                          category: category,
                          linksService: _linksService,
                          onLinkTap: _launchURL,
                          onSuccess: (message) =>
                              MessageUtils.showSuccessMessage(context, message),
                          onError: (message) =>
                              MessageUtils.showErrorMessage(context, message),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _AddFab(
        onTap: () {
          HapticFeedback.lightImpact();
          AddCategoryDialog.show(
            context,
            onCategoryAdded: (categoryName) {},
          );
        },
      ),
    );
  }
}

class _AddFab extends StatefulWidget {
  const _AddFab({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddFab> createState() => _AddFabState();
}

class _AddFabState extends State<_AddFab> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.reverse();
  void _onTapUp(TapUpDetails _) => _ctrl.forward();
  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(
        right: 20,
        bottom: (bottomPad > 0 ? bottomPad : 16) + 8,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _ctrl,
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x407C6BFF),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

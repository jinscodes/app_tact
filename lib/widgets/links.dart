import 'package:app_tact/colors.dart';
import 'package:app_tact/components/add_category_dialog.dart';
import 'package:app_tact/components/category_card.dart';
import 'package:app_tact/models/make_category.dart';
import 'package:app_tact/services/links_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:flutter/material.dart';
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.gradientPurple,
          title: Text('Open Link', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('URL:', style: TextStyle(color: Colors.grey[400])),
              SizedBox(height: 8.h),
              SelectableText(
                url,
                style: TextStyle(color: AppColors.accentPurple),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddCategoryDialog.show(
            context,
            onCategoryAdded: (categoryName) {},
          );
        },
        backgroundColor: AppColors.softPurple,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Add Category'),
      ),
    );
  }
}

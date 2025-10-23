// // ignore_for_file: use_build_context_synchronously

// import 'package:app_sticker_note/colors.dart';
// import 'package:app_sticker_note/models/category.dart';
// import 'package:app_sticker_note/services/category_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class ManageCategoryScreen extends StatefulWidget {
//   const ManageCategoryScreen({super.key});

//   @override
//   State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
// }

// class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
//   final TextEditingController _categoryController = TextEditingController();
//   final CategoryService _categoryService = CategoryService();
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _editingCategoryId;
//   final Map<String, TextEditingController> _editControllers = {};
//   List<Category> _categories = [];
//   bool _categoriesLoaded = false;
//   bool _canAddCache = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCategories();
//     _loadCategories();
//     _categoryController.addListener(_updateAddButtonState);
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final categories = await _categoryService.getCategories();
//       if (mounted) {
//         setState(() {
//           _categories = categories;
//           _categoriesLoaded = true;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _categoriesLoaded = true;
//         });
//       }
//     }
//   }

//   void _updateAddButtonState() {
//     final canAddNow = _categoryController.text.trim().isNotEmpty;
//     if (canAddNow != _canAddCache) {
//       setState(() {
//         _canAddCache = canAddNow;
//       });
//     }
//   }

//   Future<void> _initializeCategories() async {
//     try {
//       await _categoryService.initializeDefaultCategories();
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to initialize categories: ${e.toString()}';
//         });
//       }
//     }
//   }

//   Future<void> _addCategory() async {
//     if (_categoryController.text.trim().isEmpty) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       await _categoryService.addCategory(_categoryController.text.trim());
//       _categoryController.clear();
//       await _loadCategories();
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = e.toString().replaceFirst('Exception: ', '');
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(_errorMessage!),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _deleteCategory(Category category) async {
//     try {
//       await _categoryService.deleteCategory(category.id);
//       await _loadCategories();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString().replaceFirst('Exception: ', '')),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _startEditing(Category category) {
//     setState(() {
//       _editingCategoryId = category.id;
//       _editControllers[category.id] =
//           TextEditingController(text: category.name);
//     });
//   }

//   void _cancelEditing() {
//     setState(() {
//       if (_editingCategoryId != null) {
//         _editControllers[_editingCategoryId!]?.dispose();
//         _editControllers.remove(_editingCategoryId);
//         _editingCategoryId = null;
//       }
//     });
//   }

//   Future<void> _saveEdit() async {
//     if (_editingCategoryId == null) return;

//     final controller = _editControllers[_editingCategoryId!];
//     if (controller == null || controller.text.trim().isEmpty) return;

//     try {
//       await _categoryService.updateCategory(
//         _editingCategoryId!,
//         controller.text.trim(),
//       );

//       if (mounted) {
//         _cancelEditing();
//         await _loadCategories();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString().replaceFirst('Exception: ', '')),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _categoryController.removeListener(_updateAddButtonState);
//     _categoryController.dispose();
//     for (final controller in _editControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   Widget _buildCategoriesList() {
//     if (!_categoriesLoaded) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.all(20.h),
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     if (_categories.isEmpty) {
//       return Padding(
//         padding: EdgeInsets.all(20.h),
//         child: Text(
//           'No categories found. Add your first category above!',
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: Colors.grey[600],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: _categories.map((category) {
//         final isEditing = _editingCategoryId == category.id;

//         return Container(
//           margin: EdgeInsets.only(bottom: 8.h),
//           padding: EdgeInsets.symmetric(
//             horizontal: 16.w,
//             vertical: 12.h,
//           ),
//           decoration: BoxDecoration(
//             color: Color(0xFFF8F8FA),
//             borderRadius: BorderRadius.circular(8.r),
//             border: Border.all(
//               color: Colors.grey[200]!,
//               width: 1,
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.label_outline,
//                 size: 16.sp,
//                 color: Colors.grey[600],
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Row(
//                   children: [
//                     if (isEditing) ...[
//                       Expanded(
//                         child: TextField(
//                           controller: _editControllers[category.id],
//                           autofocus: true,
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.baseBlack,
//                           ),
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(4.r),
//                               borderSide: BorderSide(
//                                 color: AppColors.baseBlack,
//                                 width: 1,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(4.r),
//                               borderSide: BorderSide(
//                                 color: AppColors.baseBlack,
//                                 width: 1.5,
//                               ),
//                             ),
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 8.w,
//                               vertical: 4.h,
//                             ),
//                             isDense: true,
//                           ),
//                           onSubmitted: (_) => _saveEdit(),
//                         ),
//                       ),
//                     ] else ...[
//                       Text(
//                         category.name,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.baseBlack,
//                         ),
//                       ),
//                       if (category.isDefault) ...[
//                         SizedBox(width: 8.w),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 8.w,
//                             vertical: 4.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColors.defaultGray,
//                             borderRadius: BorderRadius.circular(8.r),
//                           ),
//                           child: Text(
//                             'Default',
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                               color: AppColors.fontGray,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ],
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (isEditing) ...[
//                     GestureDetector(
//                       onTap: _saveEdit,
//                       child: Icon(
//                         Icons.check,
//                         size: 18.sp,
//                         color: Colors.green[600],
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     GestureDetector(
//                       onTap: _cancelEditing,
//                       child: Icon(
//                         Icons.close,
//                         size: 18.sp,
//                         color: Colors.red[600],
//                       ),
//                     ),
//                   ] else ...[
//                     GestureDetector(
//                       onTap: () => _startEditing(category),
//                       child: Icon(
//                         Icons.edit_outlined,
//                         size: 18.sp,
//                         color: AppColors.baseBlack,
//                       ),
//                     ),
//                     if (!category.isDefault) ...[
//                       SizedBox(width: 8.w),
//                       GestureDetector(
//                         onTap: () => _deleteCategory(category),
//                         child: Icon(
//                           Icons.delete_outline,
//                           size: 18.sp,
//                           color: Colors.red[600],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Manage Categories',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           elevation: 0,
//           centerTitle: false,
//           forceMaterialTransparency: true,
//           backgroundColor: Colors.transparent,
//           bottom: PreferredSize(
//             preferredSize: Size.fromHeight(1.0),
//             child: Container(
//               color: Colors.grey[300],
//               height: 1.0,
//             ),
//           ),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_rounded),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 16.h),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(20.w),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey[300]!,
//                       width: 1.5,
//                     ),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Add New Category',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.normal,
//                           color: AppColors.baseBlack,
//                         ),
//                       ),
//                       SizedBox(height: 20.h),
//                       Text(
//                         "Category Name",
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.normal,
//                           color: AppColors.baseBlack,
//                         ),
//                       ),
//                       SizedBox(height: 6.h),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _categoryController,
//                               decoration: InputDecoration(
//                                 hintText: 'Enter category name',
//                                 hintStyle: TextStyle(
//                                   color: Colors.grey[500],
//                                   fontSize: 14.sp,
//                                 ),
//                                 filled: true,
//                                 fillColor: Color(0xFFF3F3F5),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.r),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.r),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.r),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 12.w,
//                                   vertical: 8.h,
//                                 ),
//                               ),
//                               onSubmitted: (_) => _addCategory(),
//                             ),
//                           ),
//                           SizedBox(width: 12.w),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: _canAddCache && !_isLoading
//                                   ? AppColors.baseBlack
//                                   : Color(0xFF8E8E95),
//                               borderRadius: BorderRadius.circular(8.r),
//                             ),
//                             child: IconButton(
//                               onPressed: _canAddCache && !_isLoading
//                                   ? _addCategory
//                                   : null,
//                               icon: _isLoading
//                                   ? SizedBox(
//                                       width: 20.sp,
//                                       height: 20.sp,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                                 Colors.white),
//                                       ),
//                                     )
//                                   : Icon(
//                                       Icons.add,
//                                       color: Colors.white,
//                                       size: 20.sp,
//                                     ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 16.w,
//                                 vertical: 8.h,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(20.w),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey[300]!,
//                       width: 1.5,
//                     ),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Existing Categories',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.normal,
//                           color: AppColors.baseBlack,
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       Text(
//                         "Manage your categories. Default categories cannot be deleted.",
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.normal,
//                           color: AppColors.baseBlack,
//                         ),
//                       ),
//                       SizedBox(height: 20.h),
//                       _buildCategoriesList(),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(20.w),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFF5F5F7),
//                     border: Border.all(
//                       color: Colors.grey[300]!,
//                       width: 1.5.w,
//                     ),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Tips:',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.normal,
//                           color: AppColors.baseBlack,
//                         ),
//                       ),
//                       SizedBox(height: 12.h),
//                       Text(
//                         "• Press Enter to quickly add a new category\n"
//                         "• Default categories (Work, Personal, Travel, Learning) cannot be deleted\n"
//                         "• You can edit category names by clicking the edit icon\n"
//                         "• Categories with existing notes will still appear even if deleted",
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.normal,
//                           color: AppColors.fontGray,
//                           height: 1.6.h,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 60.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

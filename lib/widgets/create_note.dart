// import 'package:app_sticker_note/colors.dart';
// import 'package:app_sticker_note/models/category.dart';
// import 'package:app_sticker_note/services/category_service.dart';
// import 'package:app_sticker_note/services/note_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class CreateNote extends StatefulWidget {
//   const CreateNote({super.key});

//   @override
//   State<CreateNote> createState() => _CreateNoteState();
// }

// class _CreateNoteState extends State<CreateNote> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final CategoryService _categoryService = CategoryService();
//   final NoteService _noteService = NoteService();
//   final GlobalKey _dropdownKey = GlobalKey();

//   String? _selectedCategoryId;
//   bool _isStarred = false;
//   bool _isLoading = false;
//   List<Category> _categories = [];
//   bool _categoriesLoaded = false;
//   bool _canSaveCache = false;

//   @override
//   void initState() {
//     super.initState();
//     _titleController.addListener(_updateSaveButtonState);
//     _descriptionController.addListener(_updateSaveButtonState);
//     _loadCategories();
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

//   void _updateSaveButtonState() {
//     // Calculate current save state
//     final canSaveNow = _titleController.text.trim().isNotEmpty &&
//         _descriptionController.text.trim().isNotEmpty &&
//         _selectedCategoryId != null;

//     // Only setState if the save button state actually changes
//     if (canSaveNow != _canSaveCache) {
//       setState(() {
//         _canSaveCache = canSaveNow;
//       });
//     }
//   }

//   bool get _canSave {
//     return _canSaveCache;
//   }

//   Future<void> _saveNote() async {
//     if (!_canSave || _isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _noteService.addNote(
//         title: _titleController.text.trim(),
//         description: _descriptionController.text.trim(),
//         categoryId: _selectedCategoryId!,
//         isStarred: _isStarred,
//       );

//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Note saved successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Failed to save note: ${e.toString().replaceFirst('Exception: ', '')}'),
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

//   @override
//   void dispose() {
//     _titleController.removeListener(_updateSaveButtonState);
//     _descriptionController.removeListener(_updateSaveButtonState);
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Widget _buildCategoryDropdown() {
//     if (!_categoriesLoaded) {
//       return Container(
//         height: 50.h,
//         decoration: BoxDecoration(
//           color: AppColors.inputGray,
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Center(
//           child: SizedBox(
//             width: 20.sp,
//             height: 20.sp,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//         ),
//       );
//     }

//     if (_categories.isEmpty) {
//       return Container(
//         height: 50.h,
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         decoration: BoxDecoration(
//           color: AppColors.inputGray,
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Center(
//           child: Text(
//             'No categories available',
//             style: TextStyle(
//               color: AppColors.placeholderGray,
//               fontSize: 14.sp,
//             ),
//           ),
//         ),
//       );
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.inputGray,
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: DropdownButtonFormField<String>(
//         key: _dropdownKey,
//         value: _selectedCategoryId,
//         hint: Text(
//           'Select a category',
//           style: TextStyle(
//             color: AppColors.placeholderGray,
//             fontSize: 14.sp,
//           ),
//         ),
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.r),
//             borderSide: BorderSide(
//               color: AppColors.baseBlack,
//               width: 1.5,
//             ),
//           ),
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 16.w,
//             vertical: 12.h,
//           ),
//         ),
//         style: TextStyle(
//           fontSize: 14.sp,
//           color: AppColors.baseBlack,
//         ),
//         dropdownColor: Colors.white,
//         items: _categories.map((category) {
//           return DropdownMenuItem<String>(
//             value: category.id,
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.label_outline,
//                   size: 16.sp,
//                   color: AppColors.placeholderGray,
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(category.name),
//                 if (category.isDefault) ...[
//                   SizedBox(width: 8.w),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 6.w,
//                       vertical: 2.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.defaultGray,
//                       borderRadius: BorderRadius.circular(4.r),
//                     ),
//                     child: Text(
//                       'Default',
//                       style: TextStyle(
//                         fontSize: 10.sp,
//                         color: AppColors.fontGray,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         }).toList(),
//         onChanged: (String? categoryId) {
//           setState(() {
//             _selectedCategoryId = categoryId;
//           });
//           _updateSaveButtonState();
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'New Note',
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         elevation: 0,
//         centerTitle: false,
//         forceMaterialTransparency: true,
//         backgroundColor: Colors.transparent,
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(1.0),
//           child: Container(
//             color: Colors.grey[300],
//             height: 1.0,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_rounded),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 _isStarred = !_isStarred;
//               });
//             },
//             icon: Icon(
//               _isStarred ? Icons.star : Icons.star_border_outlined,
//               color: _isStarred ? Colors.amber : null,
//             ),
//           ),
//           GestureDetector(
//             onTap: _canSave && !_isLoading ? _saveNote : null,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: _canSave && !_isLoading
//                     ? AppColors.baseBlack
//                     : AppColors.placeholderGray,
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: _isLoading
//                   ? SizedBox(
//                       width: 16.sp,
//                       height: 16.sp,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : Text(
//                       'Save',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//             ),
//           ),
//           SizedBox(width: 10.w),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 20.h),
//                 Text(
//                   'Category',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.baseBlack,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 _buildCategoryDropdown(),
//                 SizedBox(height: 20.h),
//                 Text(
//                   'Title',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.baseBlack,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 TextField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     hintText: 'Enter note title',
//                     hintStyle: TextStyle(
//                       color: AppColors.placeholderGray,
//                       fontSize: 14.sp,
//                     ),
//                     filled: true,
//                     fillColor: AppColors.inputGray,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                       borderSide: BorderSide(
//                         color: AppColors.baseBlack,
//                         width: 1.5,
//                       ),
//                     ),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 12.h,
//                     ),
//                   ),
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: AppColors.baseBlack,
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 Text(
//                   'Description',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.baseBlack,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 TextField(
//                   controller: _descriptionController,
//                   maxLines: 8,
//                   decoration: InputDecoration(
//                     hintText: 'Write your note here...',
//                     hintStyle: TextStyle(
//                       color: AppColors.placeholderGray,
//                       fontSize: 14.sp,
//                     ),
//                     filled: true,
//                     fillColor: AppColors.inputGray,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                       borderSide: BorderSide(
//                         color: AppColors.baseBlack,
//                         width: 1.5,
//                       ),
//                     ),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 12.h,
//                     ),
//                   ),
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: AppColors.baseBlack,
//                     height: 1.5,
//                   ),
//                 ),
//                 SizedBox(height: 40.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

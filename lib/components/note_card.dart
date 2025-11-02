// import 'package:app_tact/colors.dart';
// import 'package:app_tact/models/category.dart';
// import 'package:app_tact/models/note.dart';
// import 'package:app_tact/services/category_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class NoteCard extends StatelessWidget {
//   final Note note;
//   final VoidCallback? onToggleFavorite;
//   final VoidCallback? onTap;

//   const NoteCard({
//     super.key,
//     required this.note,
//     this.onToggleFavorite,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: FutureBuilder<Category?>(
//         future: _getCategoryById(note.categoryId),
//         builder: (context, categorySnapshot) {
//           final category = categorySnapshot.data;

//           return Container(
//             margin: EdgeInsets.only(bottom: 12.h),
//             padding: EdgeInsets.all(24.w),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Colors.grey[300]!,
//                 width: 1.5,
//               ),
//               borderRadius: BorderRadius.circular(12.r),
//               color: Colors.transparent,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         note.title,
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.baseBlack,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: onToggleFavorite,
//                       child: Icon(
//                         note.isStarred ? Icons.star : Icons.star_border,
//                         color: note.isStarred ? Colors.amber : Colors.grey[400],
//                         size: 20.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8.h),
//                 Row(
//                   children: [
//                     if (categorySnapshot.connectionState ==
//                         ConnectionState.waiting)
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 8.w, vertical: 4.h),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(6.r),
//                           border: Border.all(
//                             color: Colors.grey[300]!,
//                             width: 1,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(
//                               width: 10.w,
//                               height: 10.h,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 1.5,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                             SizedBox(width: 4.w),
//                             Text(
//                               'Loading...',
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     else
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 8.w,
//                           vertical: 2.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(6.r),
//                           border: Border.all(
//                             color: AppColors.inputBoldGray,
//                             width: 1,
//                           ),
//                         ),
//                         child: Text(
//                           category?.name ?? 'Unknown',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.baseBlack,
//                           ),
//                         ),
//                       ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       _formatDate(note.createdAt),
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 30.h),
//                 _buildDescription(note.description),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDescription(String description) {
//     const int maxLines = 5;

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final textPainter = TextPainter(
//           text: TextSpan(
//             text: description,
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.grey[700],
//               height: 1.4,
//             ),
//           ),
//           maxLines: maxLines,
//           textDirection: TextDirection.ltr,
//         );

//         textPainter.layout(maxWidth: constraints.maxWidth);

//         final isOverflowing = textPainter.didExceedMaxLines;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               description,
//               style: TextStyle(
//                 color: AppColors.baseBlack,
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w500,
//                 height: 1.4,
//               ),
//               maxLines: maxLines,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (isOverflowing) ...[
//               SizedBox(height: 4.h),
//               Text(
//                 '+ more items',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: AppColors.fontGray,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ],
//         );
//       },
//     );
//   }

//   Future<Category?> _getCategoryById(String categoryId) async {
//     final categoryService = CategoryService();
//     try {
//       final categoriesStream = categoryService.getCategoriesStream();
//       final categories = await categoriesStream.first;
//       return categories.firstWhere(
//         (category) => category.id == categoryId,
//         orElse: () => Category(
//           id: categoryId,
//           name: 'Unknown',
//           userId: '',
//           createdAt: DateTime.now(),
//           isDefault: false,
//         ),
//       );
//     } catch (e) {
//       return Category(
//         id: categoryId,
//         name: 'Unknown',
//         userId: '',
//         createdAt: DateTime.now(),
//         isDefault: false,
//       );
//     }
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       final weekdays = [
//         'Monday',
//         'Tuesday',
//         'Wednesday',
//         'Thursday',
//         'Friday',
//         'Saturday',
//         'Sunday'
//       ];
//       return weekdays[date.weekday - 1];
//     } else {
//       final months = [
//         'Jan',
//         'Feb',
//         'Mar',
//         'Apr',
//         'May',
//         'Jun',
//         'Jul',
//         'Aug',
//         'Sep',
//         'Oct',
//         'Nov',
//         'Dec'
//       ];
//       return '${months[date.month - 1]} ${date.day}';
//     }
//   }
// }

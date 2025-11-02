// import 'package:app_tact/colors.dart';
// import 'package:app_tact/models/category.dart';
// import 'package:app_tact/models/note.dart';
// import 'package:app_tact/services/category_service.dart';
// import 'package:app_tact/services/note_service.dart';
// import 'package:app_tact/widgets/edit_note.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class NoteDetailScreen extends StatefulWidget {
//   final Note note;

//   const NoteDetailScreen({
//     super.key,
//     required this.note,
//   });

//   @override
//   State<NoteDetailScreen> createState() => _NoteDetailScreenState();
// }

// class _NoteDetailScreenState extends State<NoteDetailScreen> {
//   final CategoryService _categoryService = CategoryService();
//   final NoteService _noteService = NoteService();
//   late Note _currentNote;

//   @override
//   void initState() {
//     super.initState();
//     _currentNote = widget.note;
//   }

//   Future<void> _toggleFavorite() async {
//     try {
//       await _noteService.toggleFavorite(_currentNote.id);
//       if (mounted) {
//         setState(() {
//           _currentNote =
//               _currentNote.copyWith(isStarred: !_currentNote.isStarred);
//         });
//       }
//     } catch (e) {
//       if (mounted && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update favorite status'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _showMoreOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2.r),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               ListTile(
//                 leading: Icon(Icons.edit, color: AppColors.baseBlack),
//                 title: Text(
//                   'Edit Note',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   await Navigator.push(
//                     context,
//                     PageRouteBuilder(
//                       pageBuilder: (context, animation, secondaryAnimation) =>
//                           EditNoteScreen(note: _currentNote),
//                       transitionDuration: const Duration(milliseconds: 300),
//                       reverseTransitionDuration:
//                           const Duration(milliseconds: 250),
//                       transitionsBuilder:
//                           (context, animation, secondaryAnimation, child) {
//                         const begin = Offset(1.0, 0.0);
//                         const end = Offset.zero;
//                         const curve = Curves.easeInOutCubic;

//                         var tween = Tween(begin: begin, end: end).chain(
//                           CurveTween(curve: curve),
//                         );

//                         var offsetAnimation = animation.drive(tween);

//                         return SlideTransition(
//                           position: offsetAnimation,
//                           child: child,
//                         );
//                       },
//                     ),
//                   );
//                   // No need to handle return value since edit screen navigates to home
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.share, color: AppColors.baseBlack),
//                 title: Text(
//                   'Share Note',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   if (mounted && context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Share feature coming soon!')),
//                     );
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.delete, color: Colors.red),
//                 title: Text(
//                   'Delete Note',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.red,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showDeleteConfirmation();
//                 },
//               ),
//               SizedBox(height: 20.h),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showDeleteConfirmation() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'Delete Note',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete this note? This action cannot be undone.',
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.grey[700],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14.sp,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 try {
//                   await _noteService.deleteNote(_currentNote.id);
//                   if (mounted && context.mounted) {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Note deleted successfully')),
//                     );
//                   }
//                 } catch (e) {
//                   if (mounted && context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Failed to delete note'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 }
//               },
//               child: Text(
//                 'Delete',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         forceMaterialTransparency: true,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_rounded,
//             color: AppColors.baseBlack,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: FutureBuilder<Category?>(
//           future: _getCategoryById(_currentNote.categoryId),
//           key: ValueKey(
//               '${_currentNote.id}_${_currentNote.categoryId}'), // Force rebuild when note changes
//           builder: (context, snapshot) {
//             final category = snapshot.data;
//             return Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 8.w,
//                     vertical: 2.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.transparent,
//                     borderRadius: BorderRadius.circular(6.r),
//                     border: Border.all(
//                       color: AppColors.inputBoldGray,
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     category?.name ?? 'Loading...',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.baseBlack,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   _formatDate(_currentNote.createdAt),
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//         centerTitle: false,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _currentNote.isStarred ? Icons.star : Icons.star_border,
//               color: _currentNote.isStarred ? Colors.amber : Colors.grey[600],
//             ),
//             onPressed: _toggleFavorite,
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.more_vert,
//               color: AppColors.baseBlack,
//             ),
//             onPressed: _showMoreOptions,
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(1.0),
//           child: Container(
//             color: Colors.grey[300],
//             height: 1.0,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 10.h),
//               Text(
//                 _currentNote.title,
//                 style: TextStyle(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.baseBlack,
//                   height: 1.3,
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               Text(
//                 _currentNote.description,
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.normal,
//                   color: AppColors.baseBlack,
//                   height: 1.6,
//                 ),
//               ),
//               SizedBox(height: 40.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<Category?> _getCategoryById(String categoryId) async {
//     try {
//       final categoriesStream = _categoryService.getCategoriesStream();
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
//       return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
//       return '${weekdays[date.weekday - 1]} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
//       return '${months[date.month - 1]} ${date.day}, ${date.year}';
//     }
//   }
// }

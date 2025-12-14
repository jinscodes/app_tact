import 'package:app_tact/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordNotAvailableDialog extends StatelessWidget {
  final String provider;

  const PasswordNotAvailableDialog({
    super.key,
    required this.provider,
  });

  static Future<void> show(BuildContext context, String provider) {
    return showDialog(
      context: context,
      builder: (context) => PasswordNotAvailableDialog(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 41, 41, 59),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.accentPurple),
          SizedBox(width: 8.w),
          Text(
            'Password Not Available',
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ],
      ),
      content: Text(
        'You signed in with $provider. Password changes are not available for social login accounts.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFB93CFF),
                Color(0xFF4F46E5),
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

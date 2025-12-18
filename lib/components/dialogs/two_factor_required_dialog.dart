import 'package:app_tact/colors.dart';
import 'package:app_tact/widgets/two_factor_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TwoFactorRequiredDialog extends StatelessWidget {
  const TwoFactorRequiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const TwoFactorRequiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.gradientPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8.w),
          Text(
            '2FA Not Set Up',
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ],
      ),
      content: Text(
        'You need to set up a 2FA password first before enabling two-factor authentication.',
        style: TextStyle(color: AppColors.textLight),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMedium),
          ),
        ),
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TwoFactorSetupScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            child: Text(
              'Set Up 2FA',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

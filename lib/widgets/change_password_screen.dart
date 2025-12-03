// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:app_tact/widgets/password_change/verify_current_password_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String? _lastPasswordChangeDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLastPasswordChange();
  }

  Future<void> _checkLastPasswordChange() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('lastPasswordChange')) {
            Timestamp timestamp = data['lastPasswordChange'];
            DateTime lastChange = timestamp.toDate();
            DateTime now = DateTime.now();
            int daysDifference = now.difference(lastChange).inDays;

            if (daysDifference < 30) {
              setState(() {
                _lastPasswordChangeDate =
                    '${lastChange.year}-${lastChange.month.toString().padLeft(2, '0')}-${lastChange.day.toString().padLeft(2, '0')}';
                _isLoading = false;
              });
              return;
            }
          }
        }
      }
    } catch (e) {
      print('Error checking last password change: $e');
    }

    setState(() {
      _isLoading = false;
    });

    // If no restriction, navigate to first step
    if (_lastPasswordChangeDate == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VerifyCurrentPasswordScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.gradientDarkBlue, AppColors.gradientPurple],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (_lastPasswordChangeDate != null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.gradientDarkBlue, AppColors.gradientPurple],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Change Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_clock,
                    size: 80.sp,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Password Change Restricted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'You changed your password on $_lastPasswordChangeDate.\n\nFor security reasons, you can only change your password once every 30 days.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    width: double.infinity,
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
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        minimumSize: Size(0, 50.h),
                      ),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // This should never be reached as we navigate away
    return Container();
  }
}

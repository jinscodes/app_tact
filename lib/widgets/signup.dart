import 'package:app_sticker_note/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _hasNameText = false;
  bool _hasEmailText = false;
  bool _hasPasswordText = false;
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Text(
            'Signup',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.baseBlack,
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                      _hasNameText = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    hintStyle: TextStyle(
                      color: AppColors.placeholderGray,
                      fontSize: 15.sp,
                    ),
                    labelText: "Full Name",
                    filled: true,
                    fillColor: AppColors.inputGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: _hasEmailText
                          ? BorderSide(
                              color: AppColors.inputBoldGray,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: AppColors.inputBoldGray,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                      _hasEmailText = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(
                      color: AppColors.placeholderGray,
                      fontSize: 15.sp,
                    ),
                    labelText: "Email",
                    filled: true,
                    fillColor: AppColors.inputGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: _hasEmailText
                          ? BorderSide(
                              color: AppColors.inputBoldGray,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: AppColors.inputBoldGray,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  obscureText: !_isPasswordVisible,
                  onChanged: (value) {
                    setState(() {
                      _hasPasswordText = value.isNotEmpty;
                      _password = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "password",
                    hintStyle: TextStyle(
                      color: AppColors.placeholderGray,
                      fontSize: 15.sp,
                    ),
                    labelText: "Password",
                    filled: true,
                    fillColor: AppColors.inputGray,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.fontGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: _hasPasswordText
                          ? BorderSide(
                              color: AppColors.inputBoldGray,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: AppColors.inputBoldGray,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Login Button Clicked $_name, $_email, $_password");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonGray,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: AppColors.fontGray,
                      fontSize: 12.sp,
                      decoration: TextDecoration.underline,
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
}

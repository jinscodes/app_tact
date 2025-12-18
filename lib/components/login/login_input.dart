// ignore_for_file: deprecated_member_use

import 'package:app_tact/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginInput extends StatefulWidget {
  final String type;
  final bool hasError;
  final bool hasText;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const LoginInput({
    super.key,
    required this.type,
    required this.hasError,
    required this.hasText,
    this.controller,
    this.onChanged,
  });

  @override
  State<LoginInput> createState() => _LoginInputState();
}

class _LoginInputState extends State<LoginInput> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
          child: Text(
            widget.type[0].toUpperCase() + widget.type.substring(1),
            style: TextStyle(
              color: AppColors.fontGray,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 60.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF3E3C47), Color(0xFF292A34)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              width: 2,
              color: widget.hasError
                  ? Colors.red.withOpacity(0.8)
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: TextField(
              controller: widget.controller,
              obscureText:
                  widget.type == 'password' ? !_isPasswordVisible : false,
              keyboardType: widget.type == 'email'
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              cursorColor: Colors.white,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 50.w,
                  vertical: 14.h,
                ),
                hintText: 'Enter your ${widget.type}',
                hintStyle: TextStyle(color: AppColors.placeholderGray),
                border: InputBorder.none,
                suffixIcon: widget.type == 'password'
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.fontGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                if (widget.onChanged != null) {
                  widget.onChanged!(v);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

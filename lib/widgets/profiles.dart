// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/utils/date_utils.dart' as AppDateUtils;
import 'package:app_tact/utils/message_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_tact/widgets/profile_info_card.dart';
import 'package:app_tact/widgets/profile_action_button.dart';
import 'package:app_tact/widgets/profile_subscription_section.dart';

class Profiles extends StatefulWidget {
  const Profiles({super.key});

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (_user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('info')
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _profileData = doc.data();
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF7B68EE),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Opening gallery...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (mounted) {
        Navigator.pop(context);
      }

      if (image == null || _user == null) return;

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF7B68EE),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Uploading image...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final String fileExtension = image.path.split('.').last.toLowerCase();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_user!.uid}.$fileExtension');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('info')
          .update({'profileImageUrl': downloadUrl});

      await _loadProfileData();

      if (mounted) {
        Navigator.pop(context);
        MessageUtils.showSuccessMessage(
          context,
          'Profile image updated successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}

        String errorMessage = 'Failed to upload image';
        if (e.toString().contains('storage')) {
          errorMessage =
              'Storage error. Please ensure Firebase Storage is enabled.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please check storage rules.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        }

        MessageUtils.showErrorMessage(
          context,
          errorMessage,
        );
      }
    }
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(
      text: _profileData?['name'] ?? _user?.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Color(0xFF2E2939),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Color(0xFF7B68EE),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        minimumSize: Size(0, 48.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFB93CFF),
                            Color(0xFF4F46E5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () async {
                            final newName = nameController.text.trim();
                            if (newName.isNotEmpty && _user != null) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_user!.uid)
                                    .collection('profile')
                                    .doc('info')
                                    .update({'name': newName});

                                await _user!.updateDisplayName(newName);
                                await _loadProfileData();

                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                print('Error updating name: $e');
                              }
                            }
                          },
                          child: Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Stack(
                children: [
                  InkWell(
                    onTap: _pickAndUploadImage,
                    borderRadius: BorderRadius.circular(60.r),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7B68EE),
                            Color(0xFF9B59B6),
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60.r,
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            _profileData?['profileImageUrl'] != null
                                ? NetworkImage(_profileData!['profileImageUrl'])
                                : null,
                        child: _profileData?['profileImageUrl'] == null
                            ? Icon(
                                Icons.person,
                                size: 60.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickAndUploadImage,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Color(0xFF7B68EE),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF2E2939),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              InkWell(
                onTap: () {
                  _showEditNameDialog();
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _profileData?['name'] ?? _user?.displayName ?? 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.edit,
                        color: Color(0xFF7B68EE),
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _profileData?['email'] ?? _user?.email ?? '',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 40.h),
              buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: _profileData?['email'] ?? _user?.email ?? 'Not provided',
                verified: _user?.emailVerified ?? false,
              ),
              buildInfoCard(
                icon: Icons.calendar_today,
                title: 'Member Since',
                value: AppDateUtils.DateUtils.formatSimpleDate(
                    _profileData?['memberSince']),
              ),
              buildInfoCard(
                icon: Icons.fingerprint,
                title: 'User ID',
                value: _profileData?['userId'] ?? _user?.uid ?? 'N/A',
              ),
              buildSubscriptionSection(_profileData),
              SizedBox(height: 30.h),
              buildActionButton(
                icon: Icons.logout,
                label: 'Logout',
                isDestructive: true,
                onPressed: () async {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

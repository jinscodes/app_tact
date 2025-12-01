// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/utils/message_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupWithGithub extends StatefulWidget {
  const SignupWithGithub({super.key});

  @override
  State<SignupWithGithub> createState() => _SignupWithGithubState();
}

class _SignupWithGithubState extends State<SignupWithGithub> {
  bool _isGitHubLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _signUpWithGitHub() async {
    print('Starting GitHub Sign-Up process...');
    setState(() {
      _isGitHubLoading = true;
    });

    try {
      print('Calling AuthService.signInWithGitHub()...');
      UserCredential? result = await _authService.signInWithGitHub();

      if (result != null && result.user != null) {
        print('GitHub Sign-Up successful! User: ${result.user!.email}');
        print('🔵 GitHub user UID: ${result.user!.uid}');

        try {
          // Reload user to ensure latest data
          await result.user!.reload();
          User? user = FirebaseAuth.instance.currentUser;
          print('🔵 User after reload: ${user?.email} (UID: ${user?.uid})');

          if (user == null) {
            print('❌ User is null after reload!');
            if (mounted) {
              MessageUtils.showErrorMessage(
                  context, 'Failed to get user information');
            }
            return;
          }

          // Check if profile already exists
          print(
              '🔵 Checking if profile exists at: users/${user.uid}/profile/info');
          final profileDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('profile')
              .doc('info')
              .get();

          print('🔵 Profile exists: ${profileDoc.exists}');

          if (!profileDoc.exists) {
            print('🔵 Creating profile for GitHub user...');
            final profileData = {
              'email': user.email,
              'memberSince': FieldValue.serverTimestamp(),
              'userId': user.uid,
              'name': user.displayName ?? 'User',
              'createdAt': FieldValue.serverTimestamp(),
              'signupType': 'github',
            };
            print('🔵 Profile data to save: $profileData');

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('profile')
                .doc('info')
                .set(profileData);
            print('✅ GitHub profile created successfully!');

            // Verify it was saved
            final verifyDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('profile')
                .doc('info')
                .get();
            print(
                '🔵 Verification - Profile exists: ${verifyDoc.exists}, Data: ${verifyDoc.data()}');
          } else {
            print('ℹ️ Profile already exists with data: ${profileDoc.data()}');
          }
        } catch (profileError, stackTrace) {
          print('❌ Error creating GitHub profile: $profileError');
          print('❌ Stack trace: $stackTrace');
          if (mounted) {
            MessageUtils.showErrorMessage(
                context, 'Failed to save profile: $profileError');
          }
        }

        if (result.additionalUserInfo?.isNewUser == true) {
          print('New GitHub user created: ${result.user!.email}');
        } else {
          print('Existing GitHub user signed in: ${result.user!.email}');
        }
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        print('GitHub sign-up was cancelled by user');
      }
    } on FirebaseAuthException catch (e) {
      print(
          'Firebase Auth error during GitHub sign-up: ${e.code} - ${e.message}');
      if (mounted) {
        String errorMessage;
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
                'An account already exists with this email using a different sign-in method.';
            break;
          case 'invalid-credential':
            errorMessage = 'GitHub authentication failed. Please try again.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'GitHub sign-up is not enabled.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          default:
            errorMessage =
                e.message ?? 'Failed to sign up with GitHub. Please try again.';
        }

        MessageUtils.showErrorMessage(context, errorMessage);
      }
    } on Exception catch (e) {
      print('General error during GitHub sign-up: $e');
      if (mounted) {
        MessageUtils.showErrorMessage(
            context, 'Failed to sign up with GitHub. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGitHubLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 48.h,
        margin: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
          color: Color(0xFF393A4D),
        ),
        child: InkWell(
          onTap: _isGitHubLoading ? null : () => _signUpWithGitHub(),
          borderRadius: BorderRadius.circular(10.r),
          child: _isGitHubLoading
              ? Center(
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.code,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'GitHub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

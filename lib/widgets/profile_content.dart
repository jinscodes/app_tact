import 'package:app_tact/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              // Profile Avatar
              Container(
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
                  child: Icon(
                    Icons.person,
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // User Name
              Text(
                _user?.displayName ?? 'User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              // User Email
              Text(
                _user?.email ?? '',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 40.h),
              // Profile Info Cards
              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: _user?.email ?? 'Not provided',
                verified: _user?.emailVerified ?? false,
              ),
              _buildInfoCard(
                icon: Icons.calendar_today,
                title: 'Member Since',
                value: _formatDate(_user?.metadata.creationTime),
              ),
              _buildInfoCard(
                icon: Icons.fingerprint,
                title: 'User ID',
                value: _user?.uid ?? 'N/A',
              ),
              SizedBox(height: 30.h),
              // Action Buttons
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit Profile',
                onPressed: () {
                  // TODO: Implement edit profile
                },
              ),
              SizedBox(height: 12.h),
              _buildActionButton(
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool verified = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFF7B68EE).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: Color(0xFF7B68EE),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13.sp,
                      ),
                    ),
                    if (verified) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.verified,
                        color: Colors.green[400],
                        size: 16.sp,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive
              ? Colors.red.withOpacity(0.2)
              : Color(0xFF7B68EE).withOpacity(0.2),
          foregroundColor: isDestructive ? Colors.red[400] : Color(0xFF7B68EE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: isDestructive
                  ? Colors.red.withOpacity(0.3)
                  : Color(0xFF7B68EE).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        icon: Icon(icon, size: 20.sp),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}

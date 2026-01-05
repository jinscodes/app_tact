import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/widgets/profile_subscription_section.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  User? _user;
  Map<String, dynamic>? _profileData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      if (_user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('profile')
            .doc('info')
            .get();
        if (doc.exists) {
          _profileData = doc.data();
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Subscription',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _loading
              ? Center(
                  child:
                      const CircularProgressIndicator(color: Color(0xFF7B68EE)),
                )
              : ListView(
                  padding: EdgeInsets.all(20.w),
                  children: [
                    SectionTitle('Subscription'),
                    buildSubscriptionSection(_profileData),
                  ],
                ),
        ),
      ),
    );
  }
}

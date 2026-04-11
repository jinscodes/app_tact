// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/services/auth_service.dart';
import 'package:app_tact/utils/date_utils.dart' as AppDateUtils;
import 'package:app_tact/utils/message_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

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
    final l = AppLocalizations.of(context);
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
                  l.profileOpeningGallery,
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

      // Check file size — limit to 2 MB
      final int fileSize = await File(image.path).length();
      const int maxBytes = 2 * 1024 * 1024; // 2 MB
      if (fileSize > maxBytes) {
        if (mounted) {
          MessageUtils.showErrorMessage(
            context,
            l.profileImageTooLarge,
          );
        }
        return;
      }

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
                  l.profileUploadingImage,
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
          l.profileImageUpdated,
        );
      }
    } catch (e) {
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}

        String errorMessage = l.profileFailedUpload;
        if (e.toString().contains('storage')) {
          errorMessage = l.profileStorageError;
        } else if (e.toString().contains('permission')) {
          errorMessage = l.profilePermissionError;
        } else if (e.toString().contains('network')) {
          errorMessage = l.profileNetworkError;
        }

        MessageUtils.showErrorMessage(
          context,
          errorMessage,
        );
      }
    }
  }

  void _showEditNameDialog() {
    final l = AppLocalizations.of(context);
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
                l.profileEditName,
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
                  hintText: l.profileEnterNameHint,
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
                        l.profileCancel,
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
                              l.profileSave,
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

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(l.profileSectionAccount),
                    SizedBox(height: 10.h),
                    _buildAccountGroup(),
                    SizedBox(height: 28.h),
                    _sectionLabel(l.profileSectionSubscription),
                    SizedBox(height: 10.h),
                    _buildSubscriptionGroup(),
                    SizedBox(height: 28.h),
                    _sectionLabel(l.profileSectionSupport),
                    SizedBox(height: 10.h),
                    _buildSupportGroup(),
                    SizedBox(height: 32.h),
                    _buildLogoutButton(),
                    SizedBox(height: 48.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final imageUrl = _profileData?['profileImageUrl'] as String?;
    final name = _profileData?['name'] ?? _user?.displayName ?? 'User';
    final email = _profileData?['email'] ?? _user?.email ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 32.h),
      child: Column(
        children: [
          // ─ Avatar ─
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar circle
                Container(
                  width: 90.r,
                  height: 90.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7C6BFF), Color(0xFFA89EFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C6BFF).withOpacity(0.30),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 90.r,
                            height: 90.r,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _avatarFallback(),
                            errorWidget: (_, __, ___) => _avatarFallback(),
                          )
                        : _avatarFallback(),
                  ),
                ),
                // Edit badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C6BFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF1F1F30), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        size: 13.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          // ─ Name ─
          GestureDetector(
            onTap: _showEditNameDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.edit_rounded,
                    size: 14.sp,
                    color: const Color(0xFF7C6BFF).withOpacity(0.80)),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          // ─ Email ─
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.50),
              fontSize: 14.sp,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Center(
        child: Icon(Icons.person_rounded, size: 44.sp, color: Colors.white),
      );

  // ─── Section helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
      );

  // ─── Account section ─────────────────────────────────────────────────────────

  Widget _buildAccountGroup() {
    final l = AppLocalizations.of(context);
    return _ProfileGroup(
      children: [
        _ProfileRow(
          icon: Icons.email_outlined,
          iconColor: const Color(0xFF5E9BFF),
          label: l.profileRowEmail,
          value: _profileData?['email'] ?? _user?.email ?? '—',
          trailing: (_user?.emailVerified ?? false)
              ? Icon(Icons.verified_rounded,
                  color: const Color(0xFF34C759), size: 14.sp)
              : null,
        ),
        _ProfileRow(
          icon: Icons.calendar_today_outlined,
          iconColor: const Color(0xFF34C759),
          label: l.profileRowMemberSince,
          value: AppDateUtils.DateUtils.formatSimpleDate(
              _profileData?['memberSince']),
        ),
        _ProfileRow(
          icon: Icons.fingerprint_rounded,
          iconColor: const Color(0xFFFF9F0A),
          label: l.profileRowUserId,
          value: _profileData?['userId'] ?? _user?.uid ?? '—',
          onTap: () {
            final uid = _profileData?['userId'] ?? _user?.uid ?? '';
            if (uid.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: uid));
              MessageUtils.showSuccessMessage(context, l.profileUserIdCopied);
            }
          },
          trailing: Icon(Icons.copy_rounded,
              size: 15.sp, color: Colors.white.withOpacity(0.22)),
        ),
      ],
    );
  }

  // ─── Subscription section ────────────────────────────────────────────────────

  Widget _buildSubscriptionGroup() {
    final l = AppLocalizations.of(context);
    final plan =
        (_profileData?['subscriptionPlan'] as String?)?.trim() ?? 'Free';
    final status =
        (_profileData?['subscriptionStatus'] as String?)?.trim() ?? 'inactive';
    final renewalRaw = _profileData?['subscriptionRenewal'] ??
        _profileData?['subscriptionValidUntil'];
    String renewal = '—';
    if (renewalRaw is Timestamp) {
      renewal = AppDateUtils.DateUtils.formatSimpleDate(renewalRaw);
    } else if (renewalRaw is String && renewalRaw.isNotEmpty) {
      renewal = renewalRaw;
    }

    final isActive =
        status.toLowerCase() == 'active' || status.toLowerCase() == 'premium';

    return _ProfileGroup(
      children: [
        _ProfileRow(
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFFAA8AFF),
          label: l.profileRowPlan,
          value: plan,
          trailing: isActive
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: const Color(0xFF34C759).withOpacity(0.30),
                        width: 1),
                  ),
                  child: Text(
                    l.profileSubActive,
                    style: TextStyle(
                        color: const Color(0xFF34C759),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600),
                  ),
                )
              : null,
        ),
        _ProfileRow(
          icon: Icons.autorenew_rounded,
          iconColor: const Color(0xFF5E9BFF),
          label: l.subRenews,
          value: renewal,
        ),
      ],
    );
  }

  // ─── Support section ─────────────────────────────────────────────────────────

  Widget _buildSupportGroup() {
    final l = AppLocalizations.of(context);
    return _ProfileGroup(
      children: [
        _ProfileRow(
          icon: Icons.help_outline_rounded,
          iconColor: const Color(0xFF5E9BFF),
          label: l.profileRowGetHelp,
          value: l.rowHelpSupport,
          onTap: () => MessageUtils.showSuccessMessage(context, l.profileComingSoon),
          trailing: Icon(Icons.chevron_right_rounded,
              size: 18.sp, color: Colors.white.withOpacity(0.25)),
        ),
        _ProfileRow(
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFFAA8AFF),
          label: l.rowVersionLabel,
          value: l.rowAbout,
          onTap: () => MessageUtils.showSuccessMessage(context, l.profileComingSoon),
          trailing: Icon(Icons.chevron_right_rounded,
              size: 18.sp, color: Colors.white.withOpacity(0.25)),
        ),
      ],
    );
  }

  // ─── Logout button ───────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return _LogoutButton(
      onTap: () async {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared private widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Grouped card container (iOS inset grouped style).
class _ProfileGroup extends StatelessWidget {
  final List<_ProfileRow> children;
  const _ProfileGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252535),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List<Widget>.generate(children.length, (i) {
          final isFirst = i == 0;
          final isLast = i == children.length - 1;
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? Radius.circular(14.r) : Radius.zero,
                  bottom: isLast ? Radius.circular(14.r) : Radius.zero,
                ),
                child: children[i],
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 56.w,
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// A single row inside a [_ProfileGroup].
class _ProfileRow extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  State<_ProfileRow> createState() => _ProfileRowState();
}

class _ProfileRowState extends State<_ProfileRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:
          widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp:
          widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel:
          widget.onTap != null ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed ? Colors.white.withOpacity(0.04) : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        child: Row(
          children: [
            // Icon pill
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 17.sp),
            ),
            SizedBox(width: 14.w),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.48),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    widget.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (widget.trailing != null) ...[
              SizedBox(width: 8.w),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Destructive logout button — outline style, no filled red background.
class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: const Color(0xFFFF453A).withOpacity(0.45),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  size: 18.sp,
                  color: const Color(0xFFFF453A).withOpacity(0.85)),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).profileLogOut,
                style: TextStyle(
                  color: const Color(0xFFFF453A).withOpacity(0.85),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

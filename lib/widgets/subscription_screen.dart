// ignore_for_file: deprecated_member_use, unused_field, unused_element

import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/services/subscription_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:app_tact/widgets/tact_paywall_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Map<String, dynamic>? _profileData;
  bool _loading = true;
  Offerings? _offerings;
  bool _purchasing = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadOfferings();
  }

  Future<void> _loadProfileData() async {
    try {
      final CustomerInfo? info =
          await SubscriptionService.instance.getCustomerInfo();
      String status = 'inactive';
      String plan = 'Free';
      String renewal = '—';

      if (info != null) {
        final activeEntitlements = info.entitlements.active;
        if (activeEntitlements.isNotEmpty) {
          status = 'active';
          // Use the first active entitlement as the plan label
          final first = activeEntitlements.values.first;
          plan = first.identifier;
          final String? exp = first.expirationDate;
          if (exp != null && exp.isNotEmpty) {
            final parsed = DateTime.tryParse(exp);
            renewal = parsed != null
                ? parsed.toLocal().toString().split(' ').first
                : exp;
          }
        }
      }

      // Map to existing helper schema
      _profileData = {
        'subscriptionPlan': plan,
        'subscriptionStatus': status,
        'subscriptionRenewal': renewal,
      };
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadOfferings() async {
    try {
      final Offerings? offerings =
          await SubscriptionService.instance.getOfferings();
      if (mounted) {
        setState(() {
          _offerings = offerings;
        });
      }
    } catch (_) {}
  }

  Future<void> _purchase(Package package) async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    final info = await SubscriptionService.instance.purchasePackage(package);
    if (mounted) {
      setState(() => _purchasing = false);
    }
    if (info != null) {
      await _loadProfileData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).subPurchaseSuccessful)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context).subPurchaseFailed)),
        );
      }
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    setState(() => _restoring = true);
    await SubscriptionService.instance.restorePurchases();
    await _loadProfileData();
    if (mounted) {
      setState(() => _restoring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).subPurchasesRestored)),
      );
    }
  }

  void _openTactPaywallPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TactPaywallPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _profileData?['subscriptionStatus'] == 'active';
    final plan =
        (_profileData?['subscriptionPlan'] as String?)?.trim() ?? 'Free';
    final renewal =
        (_profileData?['subscriptionRenewal'] as String?)?.trim() ?? '—';

    return Container(
      decoration: BoxDecoration(
        gradient: context.screenGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context).subTitle,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF7C6BFF),
                    strokeWidth: 2,
                  ),
                )
              : ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  children: [
                    // ── Plan status card ─────────────────────────────
                    _PlanStatusCard(
                        isActive: isActive, plan: plan, renewal: renewal),

                    if (!isActive) ...[
                      SizedBox(height: 16.h),
                      _UpgradeBanner(onTap: _openTactPaywallPage),
                    ],

                    SizedBox(height: 24.h),

                    // ── Section label ────────────────────────────────
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Container(
                            width: 3.w,
                            height: 13.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C6BFF),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            AppLocalizations.of(context).subSectionManage,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _SubActionRow(
                      icon: Icons.credit_card_outlined,
                      label: AppLocalizations.of(context).subUpgradeManagePlan,
                      onTap: _openTactPaywallPage,
                    ),
                    _SubActionRow(
                      icon: Icons.restore_rounded,
                      label: _restoring
                          ? AppLocalizations.of(context).subRestoring
                          : AppLocalizations.of(context).subRestorePurchases,
                      onTap: _restoring ? () {} : _restore,
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Plan status card ─────────────────────────────────────────────────────────
class _PlanStatusCard extends StatelessWidget {
  final bool isActive;
  final String plan;
  final String renewal;

  const _PlanStatusCard({
    required this.isActive,
    required this.plan,
    required this.renewal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isActive
              ? const Color(0xFF7C6BFF).withOpacity(0.5)
              : context.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6BFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: const Color(0xFF7C6BFF),
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF1DB954).withOpacity(0.15)
                          : const Color(0xFF8A8A8E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      isActive
                          ? AppLocalizations.of(context).subStatusActive
                          : AppLocalizations.of(context).subStatusInactive,
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF1DB954)
                            : const Color(0xFF8A8A8E),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isActive) ...[
            SizedBox(height: 16.h),
            Container(
              height: 1,
              color: context.borderColor,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).subRenews,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  renewal,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Upgrade banner ────────────────────────────────────────────────────────────
class _UpgradeBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _UpgradeBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C6BFF), Color(0xFF9B89FF)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).subUpgradeToPro,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    AppLocalizations.of(context).subUnlockAllFeatures,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.75), size: 20.sp),
          ],
        ),
      ),
    );
  }
}

// ── Action row ────────────────────────────────────────────────────────────────
class _SubActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SubActionRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C6BFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child:
                        Icon(icon, color: const Color(0xFF7C6BFF), size: 18.sp),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: context.textSecondary, size: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

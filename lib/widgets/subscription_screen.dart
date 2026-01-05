import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_tact/colors.dart';
import 'package:app_tact/components/common/section_title.dart';
import 'package:app_tact/widgets/profile_subscription_section.dart';
import 'package:app_tact/services/subscription_service.dart';
import 'package:app_tact/widgets/profile_action_button.dart';
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
      // Fetch RevenueCat customer info
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
      // Refresh profile section with latest entitlement
      await _loadProfileData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase failed or canceled')),
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
        const SnackBar(content: Text('Purchases restored')),
      );
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
                    SizedBox(height: 20.h),
                    if (_offerings?.current != null &&
                        _offerings!.current!.availablePackages.isNotEmpty) ...[
                      SectionTitle('Available Plans'),
                      ..._offerings!.current!.availablePackages.map((pkg) {
                        final product = pkg.storeProduct;
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                product.priceString,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              buildActionButton(
                                icon: Icons.shopping_cart,
                                label: _purchasing ? 'Purchasing…' : 'Choose',
                                onPressed:
                                    _purchasing ? () {} : () => _purchase(pkg),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      SectionTitle('Available Plans'),
                      Container(
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
                        child: Text(
                          'No plans available right now.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    buildActionButton(
                      icon: Icons.replay,
                      label: _restoring ? 'Restoring…' : 'Restore Purchases',
                      onPressed: _restoring ? () {} : _restore,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

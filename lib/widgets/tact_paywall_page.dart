// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_tact/colors.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:app_tact/services/subscription_service.dart';

class TactPaywallPage extends StatefulWidget {
  const TactPaywallPage({super.key, this.paywallMaxHeight});
  final double? paywallMaxHeight;

  @override
  State<TactPaywallPage> createState() => _TactPaywallPageState();
}

class _TactPaywallPageState extends State<TactPaywallPage> {
  Offering? _tactOffering;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    try {
      final offerings = await SubscriptionService.instance.getOfferings();
      Offering? tact;
      if (offerings != null) {
        // Try common case variants to ensure we pick the intended offering
        tact = offerings.all['Tact'] ??
            offerings.all['TACT'] ??
            offerings.all['tact'];
      }
      setState(() {
        _tactOffering = tact;
        _loading = false;
      });
      if (tact != null) {
        // Helpful runtime trace to verify which offering is rendered
        // ignore: avoid_print
        print('Paywall offering loaded: ${tact.identifier}');
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildPaywallView() {
    return PaywallView(
      offering: _tactOffering,
      onPurchaseCompleted: (customerInfo, storeTransaction) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful')),
        );
      },
      onRestoreCompleted: (customerInfo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored')),
        );
      },
      onDismiss: () {
        Navigator.of(context).maybePop();
      },
    );
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
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF7B68EE)),
              )
            : _tactOffering == null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Text(
                        'Offering "Tact" not available right now.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final maxH = widget.paywallMaxHeight != null
                          ? math.min(
                              widget.paywallMaxHeight!, constraints.maxHeight)
                          : constraints.maxHeight;

                      if (widget.paywallMaxHeight != null) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: maxH,
                            width: double.infinity,
                            child: _buildPaywallView(),
                          ),
                        );
                      }

                      return SizedBox(
                        height: maxH,
                        width: double.infinity,
                        child: _buildPaywallView(),
                      );
                    },
                  ),
      ),
    );
  }
}

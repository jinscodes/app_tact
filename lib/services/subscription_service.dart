import 'dart:io' show Platform;
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  CustomerInfo? _customerInfo;

  Future<void> init({
    required String? iosApiKey,
    required String? androidApiKey,
    String? appUserId,
    bool enableDebugLogs = false,
  }) async {
    final String? apiKey = Platform.isIOS ? iosApiKey : androidApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      return; // Skip init if no key; app will function without subscriptions
    }

    final configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);

    if (enableDebugLogs) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    if (appUserId != null && appUserId.isNotEmpty) {
      try {
        final result = await Purchases.logIn(appUserId);
        _customerInfo = result.customerInfo;
      } catch (_) {
        _customerInfo = await Purchases.getCustomerInfo();
      }
    } else {
      _customerInfo = await Purchases.getCustomerInfo();
    }

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _customerInfo = customerInfo;
    });
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      _customerInfo ??= await Purchases.getCustomerInfo();
    } catch (_) {}
    return _customerInfo;
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (_) {
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final PurchaseResult result = await Purchases.purchasePackage(package);
      _customerInfo = result.customerInfo;
      return _customerInfo;
    } catch (_) {
      return null;
    }
  }

  bool isEntitlementActive(String entitlementId) {
    final info = _customerInfo;
    if (info == null) return false;
    return info.entitlements.active.containsKey(entitlementId);
  }

  Future<void> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
    } catch (_) {}
  }
}

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initializeRevenueCat() async {
  Purchases.setLogLevel(LogLevel.debug);

  final apiKey = Platform.isIOS
      ? dotenv.env['REVENUECAT_IOS_API_KEY']
      : dotenv.env['REVENUECAT_ANDROID_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('RevenueCat API key not found in .env file');
  }

  await Purchases.configure(
    PurchasesConfiguration(apiKey),
  );
}

Future<bool> isProUser() async {
  final info = await Purchases.getCustomerInfo();
  return info.entitlements.active.containsKey('pro');
}

Future<bool> purchasePackage(Package package) async {
  try {
    final purchaseParams = PurchaseParams.package(package);
    final result = await Purchases.purchase(purchaseParams);

    return result.customerInfo.entitlements.active.containsKey('pro');
  } on PlatformException catch (e) {
    final errorCode = PurchasesErrorHelper.getErrorCode(e);

    if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
      rethrow;
    }
    return false;
  }
}

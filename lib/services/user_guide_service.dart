import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserGuideService {
  UserGuideService._();

  static const _kHideUserGuideKey = 'hide_user_guide';

  static Future<bool> shouldHideUserGuide() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kHideUserGuideKey) ?? false;
    } catch (error) {
      debugPrint('[UserGuideService] Failed to read preference: $error');
      return false;
    }
  }

  static Future<void> setHideUserGuide(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHideUserGuideKey, value);
    } catch (error) {
      debugPrint('[UserGuideService] Failed to save preference: $error');
    }
  }
}

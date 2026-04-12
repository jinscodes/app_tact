import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single-source-of-truth for the app's display language.
///
/// Lifecycle:
///   1. [init] is called once in main() before runApp.
///   2. It reads the persisted preference (SharedPreferences key "app_language").
///   3. If no preference exists, the device's system locale is used.
///      If the device locale is not in [supported], it falls back to English.
///   4. [setLanguage] persists and broadcasts the new locale immediately.
class LanguageService {
  LanguageService._();

  static const _kPrefKey = 'app_language';

  // ── Supported languages ──────────────────────────────────────────────────
  static const List<AppLanguage> supported = [
    AppLanguage(
        code: 'en', label: 'English', nativeLabel: 'English', flag: '🇺🇸'),
    AppLanguage(code: 'ko', label: 'Korean', nativeLabel: '한국어', flag: '🇰🇷'),
  ];

  // ── Current locale (observable) ──────────────────────────────────────────
  static final ValueNotifier<Locale> locale =
      ValueNotifier<Locale>(const Locale('en'));

  // ── Initialise once before runApp() ──────────────────────────────────────
  static Future<void> init() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('[LanguageService] SharedPreferences init failed: $e');
    }

    if (prefs != null) {
      final saved = prefs.getString(_kPrefKey);
      if (saved != null && _isSupported(saved)) {
        // ← Saved preference found — always honour it.
        locale.value = Locale(saved);
        return;
      }
      // Nothing saved yet — auto-detect from device locale and persist it.
      final deviceCode = _resolveDeviceCode();
      locale.value = Locale(deviceCode);
      try {
        await prefs.setString(_kPrefKey, deviceCode);
      } catch (_) {}
    } else {
      // SP unavailable — detect from device locale (will retry on next launch).
      locale.value = Locale(_resolveDeviceCode());
    }
  }

  // ── Set & persist language ────────────────────────────────────────────────
  static Future<void> setLanguage(String code) async {
    if (locale.value.languageCode == code) return;
    locale.value = Locale(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, code);
    } catch (e) {
      debugPrint('[LanguageService] Failed to persist language: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static AppLanguage get current => supported.firstWhere(
        (l) => l.code == locale.value.languageCode,
        orElse: () => supported.first,
      );

  static bool _isSupported(String code) => supported.any((l) => l.code == code);

  /// Returns the best-matching supported language code for the device locale.
  /// Checks the primary locale first, then falls back through the full list.
  static String _resolveDeviceCode() {
    final deviceLocales = ui.PlatformDispatcher.instance.locales;
    for (final deviceLocale in deviceLocales) {
      if (_isSupported(deviceLocale.languageCode)) {
        return deviceLocale.languageCode;
      }
    }
    return 'en'; // Fallback
  }
}

/// Immutable language descriptor.
class AppLanguage {
  final String code;
  final String label;
  final String nativeLabel;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.flag,
  });
}

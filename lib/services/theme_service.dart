import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single-source-of-truth for the app's theme mode (light / dark / system).
///
/// Usage:
///   await ThemeService.init();   // call once before runApp
///   ThemeService.setMode(ThemeMode.dark);
///   ValueListenableBuilder<ThemeMode>(
///     valueListenable: ThemeService.themeMode, ...)
class ThemeService {
  ThemeService._();

  static const _kPrefKey = 'app_theme';

  // ── Current theme mode (observable) ──────────────────────────────────────
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// True once the user has explicitly chosen a theme (light or dark).
  /// False on first launch — used to trigger the theme-picker screen.
  static bool hasPicked = false;

  // ── Initialise once before runApp() ──────────────────────────────────────
  static Future<void> init() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('[ThemeService] SharedPreferences init failed: $e');
    }

    if (prefs != null) {
      final saved = prefs.getString(_kPrefKey);
      if (saved != null) {
        themeMode.value = _fromString(saved);
        hasPicked = true;
        return;
      }
    }
    themeMode.value = ThemeMode.system;
    hasPicked = false;
  }

  // ── Set & persist theme mode ──────────────────────────────────────────────
  static Future<void> setMode(ThemeMode mode) async {
    themeMode.value = mode;
    hasPicked = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, _toString(mode));
    } catch (e) {
      debugPrint('[ThemeService] Failed to persist theme mode: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

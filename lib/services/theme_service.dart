import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController();

  static const _kPrefKey = 'app_theme';

  ThemeMode _themeMode = ThemeMode.system;
  bool _hasPicked = false;

  ThemeMode get themeMode => _themeMode;
  bool get hasPicked => _hasPicked;

  Future<void> loadTheme() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('[ThemeController] SharedPreferences init failed: $e');
    }

    ThemeMode nextMode = ThemeMode.system;
    bool nextHasPicked = false;

    if (prefs != null) {
      final saved = prefs.getString(_kPrefKey);
      if (saved != null) {
        nextMode = _fromString(saved);
        nextHasPicked = true;
      }
    }

    final changed = _themeMode != nextMode || _hasPicked != nextHasPicked;
    _themeMode = nextMode;
    _hasPicked = nextHasPicked;
    if (changed) {
      notifyListeners();
    }
  }

  bool setTheme(ThemeMode mode) {
    if (_themeMode == mode) {
      return false;
    }
    _themeMode = mode;
    notifyListeners();
    return true;
  }

  Future<void> persistThemeSelection() async {
    if (!_hasPicked) {
      _hasPicked = true;
      notifyListeners();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, _toString(_themeMode));
    } catch (e) {
      debugPrint('[ThemeController] Failed to persist theme mode: $e');
    }
  }

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _toString(ThemeMode mode) {
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

final ThemeController appThemeController = ThemeController();

class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found in context');
    return scope!.notifier!;
  }
}

import 'package:flutter/material.dart';

/// Adaptive color tokens — use `context.isDark`, `context.cardSurface`, etc.
/// in every widget instead of hardcoded hex colours.
extension AppThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Backgrounds / gradients ───────────────────────────────────────────────
  Color get bgGradientStart =>
      isDark ? const Color(0xFF0B0E1D) : const Color(0xFFF3F1FF);
  Color get bgGradientEnd =>
      isDark ? const Color(0xFF2E2939) : const Color(0xFFEDE9FF);

  LinearGradient get appBackgroundGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [bgGradientStart, bgGradientEnd],
      );

  /// Used by sub-screens that host their own gradient (notifications, etc.)
  LinearGradient get screenGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgGradientStart, bgGradientEnd],
        stops: const [0.0, 1.0],
      );

  // ── Surfaces ─────────────────────────────────────────────────────────────
  Color get cardSurface => isDark ? const Color(0xFF252535) : Colors.white;
  Color get inputSurface => isDark ? const Color(0xFF1A1A1A) : Colors.white;
  Color get screenSurface =>
      isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F7);
  Color get settingsLangBg =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

  // ── Text ─────────────────────────────────────────────────────────────────
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF111827);
  Color get textSecondary =>
      isDark ? const Color(0xFF8A8A8E) : const Color(0xFF6B7280);
  Color get labelColor =>
      isDark ? Colors.white.withOpacity(0.38) : const Color(0xFF9CA3AF);

  // ── Borders & dividers ────────────────────────────────────────────────────
  Color get borderColor =>
      isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB);
  Color get dividerColor =>
      isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE9ECEF);
  Color get inputBorderColor =>
      isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE5E7EB);
  Color get inputBorderFocused => const Color(0xFF7C6BFF);

  // ── Sheet-specific ────────────────────────────────────────────────────────
  Color get sheetBg => isDark ? const Color(0xFF17192B) : Colors.white;
  Color get sheetBorder =>
      isDark ? const Color(0xFF3A3F66) : const Color(0xFFE5E7EB);
  Color get sheetDivider =>
      isDark ? const Color(0xFF2E3250) : const Color(0xFFE9ECEF);
  Color get sheetText =>
      isDark ? const Color(0xFFF5F7FF) : const Color(0xFF111827);
  Color get sheetTextSec =>
      isDark ? const Color(0xFFA4ABCC) : const Color(0xFF6B7280);
  Color get sheetInputBg =>
      isDark ? const Color(0xFF2A2D45) : const Color(0xFFF3F4F6);
  Color get sheetInputBorder =>
      isDark ? const Color(0xFF444A73) : const Color(0xFFD1D5DB);
  Color get sheetSecBg =>
      isDark ? const Color(0xFF22253A) : const Color(0xFFF3F4F6);
  Color get sheetSecBorder =>
      isDark ? const Color(0xFF3A3F66) : const Color(0xFFD1D5DB);
  Color get sheetHandleColor =>
      isDark ? const Color(0xFF3A3F66) : const Color(0xFFD1D5DB);

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Color get tabBarBg =>
      isDark ? const Color(0x94272727) : const Color(0xF5FFFFFF);
  Color get tabBarTopBorder =>
      isDark ? const Color(0x1AA29BFE) : const Color(0x33A29BFE);

  // ── Notification permission sheet ─────────────────────────────────────────
  Color get notifSheetBg => isDark ? const Color(0xFF1C1828) : Colors.white;

  // ── Icon in pill on profile/settings rows ────────────────────────────────
  Color get rowChevron =>
      isDark ? Colors.white.withOpacity(0.25) : const Color(0xFFBBBBBB);

  // ── Switch track off ──────────────────────────────────────────────────────
  Color get switchTrackOff =>
      isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE0E0E0);
}

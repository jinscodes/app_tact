import 'package:flutter/material.dart';

class AppColors {
  static const Color baseBlack = Color(0xFF101827);
  static const Color fontGray = Color(0xFF9A9AA1);
  static const Color fontGray2 = Color(0xFFDEDEDE);
  static const Color fontGray3 = Color(0xFF717078);
  static const Color fontPurple = Color(0xFFD2A5FF);
  static const Color deepPurple = Color(0xFF5B3E85);
  static const Color softRed = Color(0xFF882836);
  static const Color inputGray = Color(0xFFF3F4F6);
  static const Color inputBoldGray = Color(0xFFD9D9D9);
  static const Color placeholderGray = Color(0xFF969FAB);
  static const Color forgotGray = Color(0xFF424D5C);
  static const Color buttonGray = Color(0xFF101827);
  static const Color defaultGray = Color(0xFFECECF0);
  static const Color baseBlue = Color(0xFF2E4C7F);

  // ── Purple gradient system ────────────────────────────────────────────────
  /// Primary gradient start — deep violet
  static const Color gradientStart = Color(0xFF6C5CE7);

  /// Primary gradient end — soft lavender
  static const Color gradientEnd = Color(0xFFA29BFE);

  /// Convenience alias — use wherever a single accent colour is needed
  static const Color accentPurple = gradientStart;

  /// Soft purple kept for backwards-compat cards / overlays
  static const Color softPurple = Color(0xFF6C5CE7);

  /// Full primary gradient — use for CTAs, FAB, active icons
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientEnd],
  );

  /// Subtle tinted overlay (backgrounds, card borders)
  static const Color purpleTint = Color(0x1A6C5CE7); // 10 % opacity
  static const Color purpleBorder = Color(0x4D6C5CE7); // 30 % opacity

  // ── Card surface tokens ───────────────────────────────────────────────────
  /// Card background — rgba(255,255,255, ~7 %) frosted glass
  static const Color cardSurface = Color(0x12FFFFFF);
  /// Card border — rgba(162,155,254, 15 %) soft lavender stroke
  static const Color cardBorder = Color(0x26A29BFE);
  /// Card outer glow colour for BoxShadow — rgba(108,92,231, 15 %)
  static const Color cardShadow = Color(0x266C5CE7);

  // Background / gradient base colors
  static const Color gradientDarkBlue =
      Color(0xFF07041A); // near-black indigo (top)
  static const Color gradientDarkBlue2 =
      Color(0xFF0D0921); // very dark navy-purple (mid)
  static const Color gradientPurple =
      Color(0xFF1C0E3A); // deep rich violet (bottom)
  static const Color gradientMagenta = Color(0xFF9B59B6);

  /// 3-stop deep background — use for standalone screens pushed over main nav
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientDarkBlue, gradientDarkBlue2, gradientPurple],
    stops: [0.0, 0.42, 1.0],
  );

  // Text colors
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textMedium = Color(0xFFBDBDBD);
  static const Color textDark = Color(0xFF757575);

  // Semantic colors
  static const Color errorRed = Color(0xFFEF5350);
  static const Color successGreen = Color(0xFF66BB6A);
}

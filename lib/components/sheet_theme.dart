// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens — Deep Indigo / Dark Purple system
// ─────────────────────────────────────────────────────────────────────────────

/// Bottom sheet surface (background)
const kSheetBg = Color(0xFF17192B);

/// Sheet surface gradient end (slightly lighter)
const kSheetBgEnd = Color(0xFF1B1E33);

/// Sheet border stroke
const kSheetBorder = Color(0xFF3A3F66);

/// Top corner radius for every bottom sheet
const double kSheetRadius = 24.0;

/// Recommended overlay colour — use as [barrierColor]
const kSheetBarrier = Color(0x8C000000); // rgba(0,0,0,0.55)

// ── Typography ────────────────────────────────────────────────────────────────
const kTextPrimary = Color(0xFFF5F7FF);
const kTextSecondary = Color(0xFFA4ABCC);

// ── Structure ─────────────────────────────────────────────────────────────────
const kDivider = Color(0xFF2E3250);

// ── Inputs ────────────────────────────────────────────────────────────────────
const kInputBg = Color(0xFF2A2D45);
const kInputBorder = Color(0xFF444A73);
const kInputFocus = Color(0xFF8B7CFF);

// ── Primary action (gradient) ─────────────────────────────────────────────────
const kAccentStart = Color(0xFF7768FF);
const kAccentEnd = Color(0xFF978BFF);
const kAccentGlow = Color(0x667768FF); // 40 % glow for shadow

const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [kAccentStart, kAccentEnd],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ── Secondary action ─────────────────────────────────────────────────────────
const kSecondaryBg = Color(0xFF22253A);
const kSecondaryBorder = Color(0xFF3A3F66);

// ── Layout constants ──────────────────────────────────────────────────────────
const double kSheetHPad = 20.0;
const double kSheetFieldRadius = 12.0;
const double kSheetFieldHeight = 50.0;
const double kSheetBtnHeight = 50.0;
const double kSheetBtnRadius = 14.0;
const double kSheetSectionSpacing = 22.0;
const double kSheetItemSpacing = 12.0;

// ─────────────────────────────────────────────────────────────────────────────
// showAppSheet — unified launcher
// ─────────────────────────────────────────────────────────────────────────────

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: kSheetBarrier,
    enableDrag: true,
    useSafeArea: false,
    builder: (_) => child,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSheetScaffold — the structural wrapper every sheet uses
// ─────────────────────────────────────────────────────────────────────────────

class AppSheetScaffold extends StatelessWidget {
  const AppSheetScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    this.maxHeightFactor = 0.90,
  });

  final String title;

  /// Scrollable content area between the header and sticky footer
  final Widget body;

  /// Pinned footer (typically the action buttons)
  final Widget footer;

  /// Max fraction of screen height (default 90 %)
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardH = mq.viewInsets.bottom;
    final screenH = mq.size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardH),
        child: Container(
          constraints: BoxConstraints(maxHeight: screenH * maxHeightFactor),
          decoration: BoxDecoration(
            color: kSheetBg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(kSheetRadius),
            ),
            border: const Border(
              top: BorderSide(color: kSheetBorder, width: 1),
              left: BorderSide(color: kSheetBorder, width: 1),
              right: BorderSide(color: kSheetBorder, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 48,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const _DragHandle(),

              // Title row
              _TitleRow(title: title),

              // Hair-line separator
              const _SheetDivider(),

              // Scrollable body
              Flexible(child: body),

              // Sticky footer
              footer,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: kSheetBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 16;
    return Padding(
      padding: EdgeInsets.fromLTRB(kSheetHPad, topPad, kSheetHPad, 14),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: kDivider, height: 1, thickness: 0.5);
  }
}

/// Re-usable section label  (e.g. "LINK INFO")
class SheetSectionLabel extends StatelessWidget {
  const SheetSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: kTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Field decoration factory — use for every text input inside sheets
InputDecoration sheetInputDecoration({
  required String placeholder,
  bool hasFocus = false,
}) {
  return InputDecoration(
    hintText: placeholder,
    hintStyle: const TextStyle(
      color: kTextSecondary,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: kInputBg,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kSheetFieldRadius),
      borderSide: const BorderSide(color: kInputBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kSheetFieldRadius),
      borderSide: const BorderSide(color: kInputBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kSheetFieldRadius),
      borderSide: const BorderSide(color: kInputFocus, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kSheetFieldRadius),
      borderSide: BorderSide(
        color: kInputBorder.withOpacity(0.4),
        width: 1,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Button widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Full-width gradient primary button
class SheetPrimaryButton extends StatelessWidget {
  const SheetPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: active
            ? kPrimaryGradient
            : LinearGradient(
                colors: [
                  kSheetBorder.withOpacity(0.5),
                  kSheetBorder.withOpacity(0.5),
                ],
              ),
        borderRadius: BorderRadius.circular(kSheetBtnRadius),
        boxShadow: active
            ? [
                BoxShadow(
                  color: kAccentGlow,
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: SizedBox(
        width: double.infinity,
        height: kSheetBtnHeight,
        child: ElevatedButton(
          onPressed: active ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kSheetBtnRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: active ? kTextPrimary : kTextSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Full-width secondary (outline) button
class SheetSecondaryButton extends StatelessWidget {
  const SheetSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFFF6B6B) : kTextSecondary;
    final borderColor =
        isDestructive ? const Color(0xFF7A3030) : kSecondaryBorder;
    return SizedBox(
      width: double.infinity,
      height: kSheetBtnHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: kSecondaryBg,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kSheetBtnRadius),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

/// Sticky footer container shared by all sheets
class SheetFooter extends StatelessWidget {
  const SheetFooter({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: kSheetBg,
      padding: EdgeInsets.fromLTRB(
        kSheetHPad,
        12,
        kSheetHPad,
        keyboardH > 0 ? 12 : (safeBottom > 0 ? safeBottom + 8 : 28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetDivider(),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

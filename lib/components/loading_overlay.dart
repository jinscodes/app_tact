import 'package:app_tact/components/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Color? backgroundColor;
  final Color? spinnerColor;
  final bool showGradientBackground;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.backgroundColor,
    this.spinnerColor,
    this.showGradientBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Container(
              decoration: showGradientBackground
                  ? const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF0B0E1D), Color(0xFF2E2939)],
                      ),
                    )
                  : null,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20.r,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryLoadingSpinner(
                        color: spinnerColor ?? const Color(0xFFB93CFF),
                      ),
                      if (loadingText != null) ...[
                        SizedBox(height: 16.h),
                        Text(
                          loadingText!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E2939),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Login-specific loading overlay
class LoginLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const LoginLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      showGradientBackground: true,
      backgroundColor: Colors.transparent,
      loadingText: loadingText ?? 'Signing in...',
      child: child,
    );
  }
}

// Simple inline loading widget for smaller components
class InlineLoadingSpinner extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final MainAxisAlignment alignment;
  final double spacing;

  const InlineLoadingSpinner({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingSpinner(
          size: 16.0,
          color: const Color(0xFFB93CFF),
          strokeWidth: 2.0,
        ),
        if (loadingText != null) ...[
          SizedBox(width: spacing.w),
          Text(
            loadingText!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFB93CFF),
            ),
          ),
        ],
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryLockedOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isAuthenticating;

  const CategoryLockedOverlay({
    super.key,
    required this.child,
    required this.onTap,
    this.isAuthenticating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: true,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: child,
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Semantics(
              button: true,
              label: 'This category is locked.',
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 48.h,
                  maxWidth: 260.w,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: isAuthenticating ? 0.7 : 1,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(12.r),
                      splashColor: Colors.white.withValues(alpha: 0.12),
                      highlightColor: Colors.white.withValues(alpha: 0.05),
                      child: Ink(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isAuthenticating
                                ? SizedBox(
                                    width: 20.sp,
                                    height: 20.sp,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                isAuthenticating
                                    ? 'Authenticating...'
                                    : 'This category is locked',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

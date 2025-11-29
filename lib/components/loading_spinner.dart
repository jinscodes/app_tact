import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingSpinner extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration animationDuration;
  final bool showDots;
  final String? loadingText;
  final TextStyle? textStyle;

  const LoadingSpinner({
    super.key,
    this.size = 24.0,
    this.color = Colors.white,
    this.strokeWidth = 2.0,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.showDots = false,
    this.loadingText,
    this.textStyle,
  });

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loadingText != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSpinner(),
          if (widget.loadingText != null) ...[
            SizedBox(height: 12.h),
            Text(
              widget.loadingText!,
              style: widget.textStyle ??
                  TextStyle(
                    color: widget.color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      );
    }

    return _buildSpinner();
  }

  Widget _buildSpinner() {
    if (widget.showDots) {
      return _buildDotsSpinner();
    }
    return _buildCircularSpinner();
  }

  Widget _buildCircularSpinner() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: SizedBox(
            width: widget.size.w,
            height: widget.size.h,
            child: CircularProgressIndicator(
              strokeWidth: widget.strokeWidth,
              color: widget.color,
              backgroundColor: widget.color.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsSpinner() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size.w,
          height: widget.size.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final animationValue = (_animation.value + delay) % 1.0;
              final scale = (0.5 + 0.5 * (1 - (animationValue * 2 - 1).abs()));

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size / 4,
                  height: widget.size / 4,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(scale),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// Preset loading spinners for common use cases
class LoginLoadingSpinner extends StatelessWidget {
  final String? loadingText;

  const LoginLoadingSpinner({
    super.key,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingSpinner(
      size: 20.0,
      color: Colors.white,
      strokeWidth: 2.0,
      loadingText: loadingText,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class PrimaryLoadingSpinner extends StatelessWidget {
  final String? loadingText;
  final Color? color;

  const PrimaryLoadingSpinner({
    super.key,
    this.loadingText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingSpinner(
      size: 32.0,
      color: color ?? const Color(0xFFB93CFF),
      strokeWidth: 3.0,
      loadingText: loadingText,
      textStyle: TextStyle(
        color: color ?? const Color(0xFFB93CFF),
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class DotsLoadingSpinner extends StatelessWidget {
  final String? loadingText;
  final Color? color;

  const DotsLoadingSpinner({
    super.key,
    this.loadingText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingSpinner(
      size: 40.0,
      color: color ?? const Color(0xFFB93CFF),
      showDots: true,
      loadingText: loadingText,
      animationDuration: const Duration(milliseconds: 1200),
    );
  }
}

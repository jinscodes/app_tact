import 'package:flutter/material.dart';

class BiometricBlockingOverlay extends StatefulWidget {
  final bool isVisible;

  const BiometricBlockingOverlay({
    super.key,
    required this.isVisible,
  });

  @override
  State<BiometricBlockingOverlay> createState() =>
      _BiometricBlockingOverlayState();
}

class _BiometricBlockingOverlayState extends State<BiometricBlockingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _isBlocking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      value: widget.isVisible ? 1 : 0,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _isBlocking = widget.isVisible;
  }

  @override
  void didUpdateWidget(covariant BiometricBlockingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible == oldWidget.isVisible) {
      return;
    }

    if (widget.isVisible) {
      if (!_isBlocking) {
        setState(() => _isBlocking = true);
      }
      _controller.forward();
      return;
    }

    _controller.reverse().whenComplete(() {
      if (!mounted || widget.isVisible) {
        return;
      }
      setState(() => _isBlocking = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBlocking && _controller.value == 0) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        if (_isBlocking)
          const ModalBarrier(
            dismissible: false,
            color: Colors.transparent,
          ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: FadeTransition(
              opacity: _opacity,
              child: ColoredBox(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

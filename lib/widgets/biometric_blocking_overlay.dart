import 'package:flutter/material.dart';

class BiometricBlockingOverlay extends StatelessWidget {
  final bool isVisible;

  const BiometricBlockingOverlay({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        opacity: isVisible ? 1 : 0,
        child: isVisible
            ? ModalBarrier(
                dismissible: false,
                color: Colors.black.withOpacity(0.35),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

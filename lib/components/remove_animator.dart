import 'package:flutter/material.dart';

/// Wraps a child and plays a slide-up + fade + height-collapse animation
/// when [isRemoving] flips to true. Calls [onRemoved] once the animation
/// finishes so the parent can clean up its state.
///
/// Reusable for any list item (links, categories, etc.).
class RemoveAnimator extends StatefulWidget {
  final Widget child;
  final bool isRemoving;
  final VoidCallback onRemoved;

  const RemoveAnimator({
    required super.key,
    required this.child,
    required this.isRemoving,
    required this.onRemoved,
  });

  @override
  State<RemoveAnimator> createState() => _RemoveAnimatorState();
}

class _RemoveAnimatorState extends State<RemoveAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Slight upward drift (fractional — 0.18 × item height)
  late final Animation<Offset> _slide;
  // Fade out
  late final Animation<double> _opacity;
  // Height collapse
  late final Animation<double> _size;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 270),
    );

    const curve = Curves.easeInOutCubic;

    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.18),
    ).animate(CurvedAnimation(parent: _ctrl, curve: curve));

    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _size = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: curve),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRemoved();
      }
    });
  }

  @override
  void didUpdateWidget(RemoveAnimator old) {
    super.didUpdateWidget(old);
    if (widget.isRemoving && !old.isRemoving) {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    // If the widget is removed from the tree while still animating (e.g. the
    // parent switched to an empty-state view), ensure the parent cleans up its
    // _pendingLinks / _deletingIds state so no ghost items appear on next add.
    if (_ctrl.isAnimating) {
      widget.onRemoved();
    }
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _size,
      axisAlignment: -1, // collapse from bottom up
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: widget.child,
        ),
      ),
    );
  }
}

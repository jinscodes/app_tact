// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:app_tact/components/sheet_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Public API ──────────────────────────────────────────────────────────────

/// Shows a floating undo banner at the bottom of the screen.
/// Cancels any existing banner first. Auto-dismisses after [duration].
/// If [onUndo] is pressed the timer is cancelled and the callback fires.
void showUndoBanner({
  required BuildContext context,
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(milliseconds: 2500),
}) {
  _UndoBannerController._instance?.dismiss();
  _UndoBannerController._instance =
      _UndoBannerController._show(context, message, onUndo, duration);
}

// ─── Internal controller ──────────────────────────────────────────────────────

class _UndoBannerController {
  static _UndoBannerController? _instance;

  final OverlayEntry _entry;
  final _BannerState _state;
  Timer? _timer;

  _UndoBannerController._(this._entry, this._state);

  static _UndoBannerController _show(
    BuildContext context,
    String message,
    VoidCallback onUndo,
    Duration duration,
  ) {
    late _UndoBannerController ctrl;

    final state = _BannerState();

    final entry = OverlayEntry(
      builder: (_) => _UndoBannerWidget(
        message: message,
        state: state,
        onUndo: () {
          ctrl._timer?.cancel();
          ctrl._timer = null;
          onUndo();
          ctrl.dismiss();
        },
        onDismissed: () {
          ctrl._entry.remove();
          if (_instance == ctrl) _instance = null;
        },
      ),
    );

    Overlay.of(context).insert(entry);

    ctrl = _UndoBannerController._(entry, state);
    ctrl._timer = Timer(duration, ctrl.dismiss);
    return ctrl;
  }

  void dismiss() {
    _timer?.cancel();
    _timer = null;
    _state.hide();
  }
}

// ─── State holder passed into the overlay widget ──────────────────────────────

class _BannerState extends ChangeNotifier {
  bool _visible = true;
  bool get visible => _visible;

  void hide() {
    if (!_visible) return;
    _visible = false;
    notifyListeners();
  }
}

// ─── Overlay widget ───────────────────────────────────────────────────────────

class _UndoBannerWidget extends StatefulWidget {
  final String message;
  final _BannerState state;
  final VoidCallback onUndo;
  final VoidCallback onDismissed;

  const _UndoBannerWidget({
    required this.message,
    required this.state,
    required this.onUndo,
    required this.onDismissed,
  });

  @override
  State<_UndoBannerWidget> createState() => _UndoBannerWidgetState();
}

class _UndoBannerWidgetState extends State<_UndoBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    widget.state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (!widget.state.visible) {
      // Reverse: slide down + fade out
      _ctrl.reverse().whenComplete(widget.onDismissed);
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: kSheetBg,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: kSheetBorder, width: 0.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded,
                      color: kTextSecondary, size: 18),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: widget.onUndo,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      child: Text(
                        'Undo',
                        style: TextStyle(
                          color: const Color(0xFFB93CFF),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

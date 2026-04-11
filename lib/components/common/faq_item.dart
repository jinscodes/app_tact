import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _kFaqAccent = Color(0xFF7C6BFF);
const _kFaqSurface = Color(0xFF1A1A1A);
const _kFaqBorder = Color(0x1FFFFFFF);

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: _kFaqSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _expanded ? _kFaqAccent.withOpacity(0.35) : _kFaqBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: _kFaqAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.help_outline_rounded,
                          color: _kFaqAccent,
                          size: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF8A8A8E),
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: _expanded
                      ? Padding(
                          padding: EdgeInsets.only(top: 12.h, left: 40.w),
                          child: Text(
                            widget.answer,
                            style: TextStyle(
                              color: const Color(0xFF8A8A8E),
                              fontSize: 13.sp,
                              height: 1.6,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

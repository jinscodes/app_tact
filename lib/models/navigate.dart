import 'package:flutter/material.dart';

class Navigate {
  static Route<T> _createSmoothRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  static Route<T> _createFadeRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static Route<T> _createScaleRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        var scaleAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static void to(BuildContext context, String path, {Object? arguments}) {
    Navigator.pushNamed(context, path, arguments: arguments);
  }

  static void toSmooth(BuildContext context, Widget page) {
    Navigator.push(context, _createSmoothRoute(page));
  }

  static void toFade(BuildContext context, Widget page) {
    Navigator.push(context, _createFadeRoute(page));
  }

  static void toScale(BuildContext context, Widget page) {
    Navigator.push(context, _createScaleRoute(page));
  }

  static void replace(BuildContext context, String path, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, path, arguments: arguments);
  }

  static void replaceSmooth(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, _createSmoothRoute(page));
  }

  static void replaceFade(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, _createFadeRoute(page));
  }

  static void popUntilRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static void toAndRemoveUntil(BuildContext context, String path) {
    Navigator.pushNamedAndRemoveUntil(context, path, (route) => false);
  }

  static void toAndRemoveUntilSmooth(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
        context, _createFadeRoute(page), (route) => false);
  }
}

import 'package:flutter/material.dart';

class Navigate {
  static void to(BuildContext context, String path, {Object? arguments}) {
    Navigator.pushNamed(context, path, arguments: arguments);
  }

  static void replace(BuildContext context, String path, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, path, arguments: arguments);
  }

  static void popUntilRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static void toAndRemoveUntil(BuildContext context, String path) {
    Navigator.pushNamedAndRemoveUntil(context, path, (route) => false);
  }
}

import 'package:flutter/widgets.dart';

class InputUtils {
  static void handleDigitChange(
    int index,
    String value,
    List<FocusNode> focusNodes,
  ) {
    if (value.isNotEmpty && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  static void clearFields(
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    for (var controller in controllers) {
      controller.clear();
    }
    if (focusNodes.isNotEmpty) {
      focusNodes[0].requestFocus();
    }
  }

  static String getEnteredCode(List<TextEditingController> controllers) {
    return controllers.map((c) => c.text).join();
  }
}

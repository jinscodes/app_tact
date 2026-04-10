// ignore_for_file: deprecated_member_use

import 'package:app_tact/components/sheet_theme.dart';
import 'package:flutter/material.dart';

class DeleteLinkDialog {
  static void show(
    BuildContext context, {
    required String linkTitle,
    required VoidCallback onConfirm,
  }) {
    showAppSheet(
      context: context,
      child: _DeleteLinkSheet(
        linkTitle: linkTitle,
        onConfirm: onConfirm,
      ),
    );
  }
}

class _DeleteLinkSheet extends StatelessWidget {
  const _DeleteLinkSheet({
    required this.linkTitle,
    required this.onConfirm,
  });

  final String linkTitle;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Delete Link',
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          kSheetHPad,
          kSheetSectionSpacing,
          kSheetHPad,
          kSheetSectionSpacing,
        ),
        child: Center(
          child: Text(
            'Delete "$linkTitle"?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ),
      footer: SheetFooter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetSecondaryButton(
              label: 'Delete',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                onConfirm();
              },
            ),
            const SizedBox(height: 10),
            SheetSecondaryButton(
              label: 'Cancel',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

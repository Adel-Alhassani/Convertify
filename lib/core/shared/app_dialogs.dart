import 'package:convertify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dialogs and toasts used outside the convert flow. Errors inside the flow
/// are shown inline on the convert screen instead.
class AppDialogs {
  static Future<void> showMessage(String title, String message) {
    return Get.dialog<void>(
      Builder(builder: (context) {
        return _AppDialog(
          title: title,
          message: message,
          actions: [
            FilledButton(
              onPressed: () => Get.back(),
              style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
              child: Text("ok".tr),
            ),
          ],
        );
      }),
    );
  }

  /// Returns true when the user confirms.
  static Future<bool> confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await Get.dialog<bool>(
      Builder(builder: (context) {
        final c = context.colors;
        return _AppDialog(
          title: title,
          message: message,
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("cancel".tr),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              style: FilledButton.styleFrom(
                minimumSize: const Size(96, 48),
                backgroundColor: destructive ? c.danger : c.primary,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      }),
    );
    return result ?? false;
  }

  static void showToast(String message) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AppDialog extends StatelessWidget {
  const _AppDialog(
      {required this.title, required this.message, required this.actions});

  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: text.titleLarge),
            const SizedBox(height: 8),
            Text(message, style: text.bodyMedium),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

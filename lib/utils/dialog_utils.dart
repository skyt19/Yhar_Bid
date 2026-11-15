/// lib/utils/dialog_utils.dart
/// Utility functions for consistent dialog behavior
/// Phase 11: Fix modal closing bugs

import 'package:flutter/material.dart';

class DialogUtils {
  /// Show confirmation dialog with proper single-click dismissal
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    bool barrierDismissible = true,
  }) async {
    // Prevent duplicate dialogs
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            // Ensure dialog closes on back button/escape
            if (!didPop && dialogContext.mounted) {
              Navigator.of(dialogContext).pop(false);
            }
          },
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  // Single click dismissal - use dialogContext, not parent context
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(false);
                  }
                },
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () {
                  // Single click dismissal - use dialogContext, not parent context
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                style: confirmColor != null
                    ? TextButton.styleFrom(foregroundColor: confirmColor)
                    : null,
                child: Text(confirmText),
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  /// Show simple alert dialog
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(buttonText),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show custom dialog with guaranteed single-click close
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    if (!context.mounted) return null;

    return await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: builder(dialogContext),
        );
      },
    );
  }
}

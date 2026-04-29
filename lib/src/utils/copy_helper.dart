import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clipboard helper that copies text and shows a confirmation snackbar.
///
/// Uses [Clipboard.setData] directly — no `share_plus` dependency needed.
class CopyHelper {
  /// Copies [text] to the clipboard and shows a snackbar with [label].
  ///
  /// If the [context] is no longer mounted, fails silently.
  static Future<void> copy({
    required BuildContext context,
    required String text,
    required String label,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$label copied',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}

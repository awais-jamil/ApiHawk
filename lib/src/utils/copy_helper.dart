
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clipboard helper that copies text and shows a confirmation snackbar.
///
/// Uses [Clipboard.setData] directly — no `share_plus` dependency needed.
/// In debug mode, also logs the copied text to the console
/// so it's accessible even when the simulator clipboard doesn't sync.
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

    // In debug mode, print to console so devs can copy from IDE terminal
    // when the simulator clipboard doesn't sync to macOS.
    if (kDebugMode) {
      // Using debugPrint (not developer.log) ensures output is always
      // visible in the IDE console and `flutter run` terminal.
      debugPrint('');
      debugPrint('══════ API Hawk: $label ══════');
      debugPrint(text);
      debugPrint('══════════════════════════════');
      debugPrint('');
    }

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
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          action: kDebugMode
              ? SnackBarAction(
                  label: 'VIEW',
                  textColor: Colors.cyanAccent,
                  onPressed: () => _showTextDialog(context, label, text),
                )
              : null,
        ),
      );
  }

  /// Shows a dialog with selectable text — fallback for simulator.
  static void _showTextDialog(
    BuildContext context,
    String label,
    String text,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

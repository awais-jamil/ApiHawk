import 'dart:developer' as developer;
import 'dart:io' show stdout;

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
  ///
  /// An optional [messenger] can be provided to show the snackbar on a
  /// specific [ScaffoldMessengerState] — useful when the calling context
  /// may become unmounted (e.g. after popping a bottom sheet).
  static Future<void> copy({
    required BuildContext context,
    required String text,
    required String label,
    ScaffoldMessengerState? messenger,
  }) async {
    // Log to console FIRST (before clipboard, which can throw on simulator).
    // Two output channels cover all environments:
    //  • developer.log  → Android Studio Run tab, VS Code Debug Console
    //  • stdout.writeln  → terminal `flutter run`
    // Both bypass runZonedGuarded zones that can swallow print()/debugPrint().
    // Only in debug mode — no output in release builds.
    if (kDebugMode) {
      final logBlock = '\n'
          '══════ API Hawk: $label ══════\n'
          '$text\n'
          '══════════════════════════════\n';

      // VM service protocol — shows in Android Studio & VS Code.
      developer.log(logBlock, name: 'ApiHawk');

      // Raw stdout — shows in terminal `flutter run`.
      stdout.writeln(logBlock);
    }

    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (_) {
      // Clipboard can fail on iOS simulator — ignore silently.
    }

    // Determine the ScaffoldMessenger to use for the snackbar.
    // Prefer the explicitly passed messenger (e.g. from a bottom sheet that
    // captured the detail screen's messenger before popping). Fall back to
    // looking up from context if still mounted.
    final ScaffoldMessengerState? effectiveMessenger;
    if (messenger != null && messenger.mounted) {
      effectiveMessenger = messenger;
    } else if (context.mounted) {
      effectiveMessenger = ScaffoldMessenger.of(context);
    } else {
      return;
    }

    effectiveMessenger
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
                  onPressed: () {
                    if (!context.mounted) return;
                    _showTextDialog(context, label, text);
                  },
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
    if (!context.mounted) return;
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

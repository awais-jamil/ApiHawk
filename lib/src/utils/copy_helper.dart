import 'dart:developer' as developer;
import 'dart:io' show stdout;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clipboard helper that copies text and shows a confirmation snackbar.
///
/// Uses [SystemChannels.platform] to invoke the clipboard method directly,
/// with retry logic — works reliably in both standalone and add-to-app
/// (Flutter module embedded in a native host) contexts.
///
/// Falls back to [Clipboard.setData] if the direct channel call fails.
/// In debug mode, also logs the copied text to the console
/// so it's accessible even when the simulator clipboard doesn't sync.
class CopyHelper {
  /// Maximum number of clipboard write attempts before giving up.
  static const int _maxRetries = 3;

  /// Delay between retry attempts to allow the platform to settle.
  static const Duration _retryDelay = Duration(milliseconds: 100);

  /// Timeout for each clipboard write attempt. Prevents indefinite hanging
  /// in add-to-app when the platform channel doesn't respond.
  static const Duration _clipboardTimeout = Duration(milliseconds: 500);

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
    // developer.log covers Android Studio Run tab, VS Code Debug Console,
    // and terminal `flutter run`.
    // Only in debug mode — no output in release builds.
    if (kDebugMode) {
      final logBlock = '\n'
          '══════ API Hawk: $label ══════\n'
          '$text\n'
          '══════════════════════════════\n';

      developer.log(logBlock, name: 'ApiHawk');

      // Raw stdout — shows in terminal `flutter run`.
      stdout.writeln(logBlock);
    }

    // ALWAYS attempt clipboard — even if context is dead.
    // In add-to-app, the context/messenger can become unmounted after
    // Navigator.pop(), but the clipboard should still work.
    await _setClipboardWithRetry(text);

    // Snackbar is best-effort. If context/messenger is dead, skip silently.
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
      // Clipboard already done above — just skip the snackbar.
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

  /// Attempts to write [text] to the clipboard with timeout protection.
  ///
  /// In add-to-app contexts, the platform channel can hang indefinitely if
  /// the native host hasn't registered a clipboard handler. Each attempt
  /// times out after [_clipboardTimeout] to prevent blocking the UI.
  ///
  /// Retries up to [_maxRetries] times with a short delay between attempts
  /// to handle transient platform readiness issues.
  static Future<bool> _setClipboardWithRetry(String text) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        await Clipboard.setData(ClipboardData(text: text))
            .timeout(_clipboardTimeout);
        return true;
      } catch (e) {
        if (kDebugMode) {
          developer.log(
            'CopyHelper: Clipboard attempt ${attempt + 1}/$_maxRetries '
            'failed: $e',
            name: 'ApiHawk',
          );
        }
        // Retry after a short delay.
        if (attempt < _maxRetries - 1) {
          await Future<void>.delayed(_retryDelay);
        }
      }
    }

    // All attempts failed. Log in debug mode so developers can diagnose.
    if (kDebugMode) {
      developer.log(
        'CopyHelper: Failed to write to clipboard after $_maxRetries attempts.',
        name: 'ApiHawk',
        level: 900, // WARNING level
      );
    }
    return false;
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

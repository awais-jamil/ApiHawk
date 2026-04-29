import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/ui/theme/hawk_theme.dart';
import 'package:api_hawk/src/utils/copy_helper.dart';
import 'package:flutter/material.dart';

/// Error tab showing error message and stack trace.
class ErrorTab extends StatelessWidget {
  const ErrorTab({super.key, required this.call});

  final HawkHttpCall call;

  @override
  Widget build(BuildContext context) {
    final err = call.error;

    if (err == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: HawkColors.success.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No errors',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    final errorStr = err.error?.toString() ?? 'Unknown error';
    final stackStr = err.stackTrace?.toString();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Error message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HawkColors.clientError.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: HawkColors.clientError.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: HawkColors.clientError,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Error',
                    style: TextStyle(
                      color: HawkColors.clientError,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => CopyHelper.copy(
                      context: context,
                      text: errorStr,
                      label: 'Error message',
                    ),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SelectableText(
                errorStr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Stack trace
        if (stackStr != null && stackStr.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Stack Trace',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              InkWell(
                onTap: () => CopyHelper.copy(
                  context: context,
                  text: stackStr,
                  label: 'Stack trace',
                ),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: SelectableText(
              stackStr,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.white54,
                height: 1.6,
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}

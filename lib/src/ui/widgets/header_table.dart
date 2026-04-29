import 'package:api_hawk/src/utils/copy_helper.dart';
import 'package:flutter/material.dart';

/// Displays a key-value table for HTTP headers or similar maps.
///
/// Each row shows the key on the left and value on the right.
/// Long-press on any row copies its value to the clipboard.
class HeaderTable extends StatelessWidget {
  const HeaderTable({
    super.key,
    required this.headers,
    this.title,
  });

  final Map<String, dynamic> headers;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimColor = theme.colorScheme.onSurfaceVariant;

    if (headers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No ${title?.toLowerCase() ?? 'data'}',
            style: TextStyle(color: dimColor, fontSize: 13),
          ),
        ),
      );
    }

    final entries = headers.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          _HeaderRow(
            entryKey: entries[i].key,
            entryValue: entries[i].value.toString(),
          ),
          if (i < entries.length - 1)
            Divider(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.3),
            ),
        ],
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.entryKey,
    required this.entryValue,
  });

  final String entryKey;
  final String entryValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimColor = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onLongPress: () => CopyHelper.copy(
        context: context,
        text: '$entryKey: $entryValue',
        label: entryKey,
      ),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                entryKey,
                style: TextStyle(
                  color: dimColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entryValue,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

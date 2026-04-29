import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/ui/widgets/header_table.dart';
import 'package:api_hawk/src/ui/widgets/json_viewer.dart';
import 'package:api_hawk/src/utils/call_formatter.dart';
import 'package:api_hawk/src/utils/copy_helper.dart';
import 'package:flutter/material.dart';

/// Response tab showing status, headers, and body.
class ResponseTab extends StatelessWidget {
  const ResponseTab({super.key, required this.call});

  final HawkHttpCall call;

  @override
  Widget build(BuildContext context) {
    final res = call.response;
    if (res == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              call.loading ? Icons.hourglass_top : Icons.cloud_off,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              call.loading ? 'Waiting for response...' : 'No response received',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Headers section
        _SectionHeader(
          title: 'Headers (${res.headers.length})',
          onCopy: () => CopyHelper.copy(
            context: context,
            text: CallFormatter.formatHeaders(
              Map<String, dynamic>.from(res.headers),
            ),
            label: 'Response headers',
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: HeaderTable(
            headers: Map<String, dynamic>.from(res.headers),
            title: 'headers',
          ),
        ),

        // Body
        if (res.body != null) ...[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: JsonViewerToggle(
              data: res.body,
              onCopy: () => CopyHelper.copy(
                context: context,
                text: CallFormatter.formatBody(res.body),
                label: 'Response body',
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onCopy,
  });

  final String title;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
          const Spacer(),
          if (onCopy != null)
            InkWell(
              onTap: onCopy,
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
    );
  }
}

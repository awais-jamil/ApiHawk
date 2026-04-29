import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/ui/widgets/header_table.dart';
import 'package:api_hawk/src/ui/widgets/json_viewer.dart';
import 'package:api_hawk/src/utils/call_formatter.dart';
import 'package:api_hawk/src/utils/copy_helper.dart';
import 'package:flutter/material.dart';

/// Request tab showing headers, query parameters, and body.
class RequestTab extends StatelessWidget {
  const RequestTab({super.key, required this.call});

  final HawkHttpCall call;

  @override
  Widget build(BuildContext context) {
    final req = call.request;
    if (req == null) {
      return const Center(
        child: Text('No request data', style: TextStyle(color: Colors.grey)),
      );
    }

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Headers section
        _SectionHeader(
          title: 'Headers (${req.headers.length})',
          onCopy: () => CopyHelper.copy(
            context: context,
            text: CallFormatter.formatHeaders(req.headers),
            label: 'Request headers',
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
            headers: req.headers,
            title: 'headers',
          ),
        ),

        // Query parameters
        if (req.queryParameters.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Query Parameters (${req.queryParameters.length})',
            onCopy: () => CopyHelper.copy(
              context: context,
              text: CallFormatter.formatHeaders(req.queryParameters),
              label: 'Query parameters',
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
              headers: req.queryParameters,
              title: 'parameters',
            ),
          ),
        ],

        // Form data
        if (req.formDataFields.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Form Fields (${req.formDataFields.length})',
            onCopy: () => CopyHelper.copy(
              context: context,
              text: req.formDataFields
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n'),
              label: 'Form fields',
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
              headers: Map.fromEntries(
                req.formDataFields.map((e) => MapEntry(e.key, e.value)),
              ),
              title: 'fields',
            ),
          ),
        ],

        if (req.formDataFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Form Files (${req.formDataFiles.length})',
            onCopy: null,
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
              headers: Map.fromEntries(
                req.formDataFiles.map((e) => MapEntry(e.key, e.value)),
              ),
              title: 'files',
            ),
          ),
        ],

        // Body
        if (req.body != null &&
            req.body.toString().isNotEmpty &&
            req.body != 'Form Data') ...[
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
              data: req.body,
              onCopy: () => CopyHelper.copy(
                context: context,
                text: CallFormatter.formatBody(req.body),
                label: 'Request body',
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

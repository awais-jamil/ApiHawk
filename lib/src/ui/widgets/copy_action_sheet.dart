import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/utils/call_formatter.dart';
import 'package:api_hawk/src/utils/copy_helper.dart';
import 'package:api_hawk/src/utils/curl_generator.dart';
import 'package:flutter/material.dart';

/// Bottom sheet with granular copy/share options for an HTTP call.
///
/// Each option copies a specific piece of data to the clipboard:
/// URL, request headers, request body, response headers, response body,
/// cURL command, or the full call log.
class CopyActionSheet extends StatelessWidget {
  const CopyActionSheet({
    super.key,
    required this.call,
  });

  final HawkHttpCall call;

  /// Shows this sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, HawkHttpCall call) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CopyActionSheet(call: call),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.copy_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Copy & Share',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),

            // URL
            _CopyTile(
              icon: Icons.link,
              label: 'Copy URL',
              onTap: () => _copyAndPop(
                context,
                call.uri,
                'URL',
              ),
            ),

            // Request Headers
            if (call.request != null &&
                call.request!.headers.isNotEmpty)
              _CopyTile(
                icon: Icons.arrow_upward_rounded,
                label: 'Copy Request Headers',
                onTap: () => _copyAndPop(
                  context,
                  CallFormatter.formatHeaders(call.request!.headers),
                  'Request headers',
                ),
              ),

            // Request Body
            if (call.request?.body != null)
              _CopyTile(
                icon: Icons.data_object,
                label: 'Copy Request Body',
                onTap: () => _copyAndPop(
                  context,
                  CallFormatter.formatBody(call.request!.body),
                  'Request body',
                ),
              ),

            // Response Headers
            if (call.response != null &&
                call.response!.headers.isNotEmpty)
              _CopyTile(
                icon: Icons.arrow_downward_rounded,
                label: 'Copy Response Headers',
                onTap: () => _copyAndPop(
                  context,
                  CallFormatter.formatHeaders(
                    Map<String, dynamic>.from(call.response!.headers),
                  ),
                  'Response headers',
                ),
              ),

            // Response Body
            if (call.response?.body != null)
              _CopyTile(
                icon: Icons.data_array,
                label: 'Copy Response Body',
                onTap: () => _copyAndPop(
                  context,
                  CallFormatter.formatBody(call.response!.body),
                  'Response body',
                ),
              ),

            const Divider(),

            // cURL
            _CopyTile(
              icon: Icons.terminal,
              label: 'Copy as cURL',
              subtitle: 'Ready to paste in terminal',
              onTap: () => _copyAndPop(
                context,
                CurlGenerator.generate(call),
                'cURL command',
              ),
            ),

            // Full call
            _CopyTile(
              icon: Icons.description_outlined,
              label: 'Copy Full Call Log',
              subtitle: 'Request + Response + Error + cURL',
              onTap: () => _copyAndPop(
                context,
                CallFormatter.formatFullCall(call),
                'Full call log',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyAndPop(
    BuildContext context,
    String text,
    String label,
  ) async {
    Navigator.of(context).pop();
    await CopyHelper.copy(context: context, text: text, label: label);
  }
}

class _CopyTile extends StatelessWidget {
  const _CopyTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, size: 20, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.content_copy,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      dense: true,
      onTap: onTap,
    );
  }
}

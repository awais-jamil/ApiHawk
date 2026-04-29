import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/ui/theme/hawk_theme.dart';
import 'package:api_hawk/src/ui/widgets/method_badge.dart';
import 'package:api_hawk/src/ui/widgets/status_badge.dart';
import 'package:api_hawk/src/utils/call_formatter.dart';
import 'package:flutter/material.dart';

/// A single row in the call list representing one HTTP call.
///
/// Shows: method badge, URL path, status badge, duration, and timestamp.
class CallListItem extends StatelessWidget {
  const CallListItem({
    super.key,
    required this.call,
    required this.onTap,
  });

  final HawkHttpCall call;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationColor = HawkColors.forDuration(call.duration);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Method badge
              MethodBadge(method: call.method, compact: true),
              const SizedBox(width: 10),

              // URL + timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.displayPath,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${call.server}  •  ${CallFormatter.formatTime(call.createdTime)}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Duration + Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    statusText: call.statusText,
                    statusCode: call.response?.statusCode,
                    isLoading: call.loading,
                    isError: call.isError,
                  ),
                  const SizedBox(height: 4),
                  if (call.loading)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: HawkColors.loading,
                      ),
                    )
                  else
                    Text(
                      CallFormatter.formatDuration(call.duration),
                      style: TextStyle(
                        color: durationColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

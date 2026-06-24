import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/ui/theme/hawk_theme.dart';
import 'package:api_hawk/src/ui/widgets/method_badge.dart';
import 'package:api_hawk/src/ui/widgets/status_badge.dart';
import 'package:api_hawk/src/utils/call_formatter.dart';
import 'package:flutter/material.dart';

/// A single row in the call list representing one HTTP call.
///
/// Shows: method badge, URL path, status badge, duration, and timestamp.
/// Failed calls (4xx, 5xx, or network errors) are visually distinguished
/// with a red-tinted background and border.
class CallListItem extends StatelessWidget {
  const CallListItem({
    super.key,
    required this.call,
    required this.onTap,
  });

  final HawkHttpCall call;
  final VoidCallback onTap;

  /// Whether this call has a failing status (4xx, 5xx, or network error).
  bool get _isFailed {
    if (call.loading) return false;
    if (call.error != null) return true;
    final code = call.response?.statusCode ?? 0;
    return code >= 400 || code == 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationColor = HawkColors.forDuration(call.duration);
    final isFailed = _isFailed;

    // Determine error color based on error type.
    final Color errorAccent;
    final statusCode = call.response?.statusCode ?? 0;
    if (statusCode >= 500) {
      errorAccent = HawkColors.serverError;
    } else if (statusCode >= 400) {
      errorAccent = HawkColors.clientError;
    } else {
      errorAccent = HawkColors.networkError;
    }

    return Card(
      color: isFailed ? errorAccent.withValues(alpha: 0.06) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isFailed
              ? errorAccent.withValues(alpha: 0.35)
              : theme.dividerColor,
          width: isFailed ? 1.0 : 0.5,
        ),
      ),
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
                    Row(
                      children: [
                        // Show a small error icon for failed calls.
                        if (isFailed) ...[
                          Icon(
                            call.error != null && call.response == null
                                ? Icons.wifi_off_rounded
                                : Icons.error_outline_rounded,
                            size: 12,
                            color: errorAccent.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            '${call.server}  •  ${CallFormatter.formatTime(call.createdTime)}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                    const SizedBox(
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

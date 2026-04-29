import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/ui/theme/hawk_theme.dart';
import 'package:api_hawk/src/ui/widgets/method_badge.dart';
import 'package:api_hawk/src/ui/widgets/status_badge.dart';
import 'package:api_hawk/src/utils/call_formatter.dart';
import 'package:api_hawk/src/utils/copy_helper.dart';
import 'package:flutter/material.dart';

/// Overview tab showing general information about an HTTP call.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.call});

  final HawkHttpCall call;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimColor = theme.colorScheme.onSurfaceVariant;
    final durationColor = HawkColors.forDuration(call.duration);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status + Method hero card
        _HeroCard(call: call, durationColor: durationColor),

        const SizedBox(height: 16),

        // Details
        _SectionCard(
          children: [
            _InfoRow(
              label: 'URL',
              value: call.uri,
              onCopy: () => CopyHelper.copy(
                context: context,
                text: call.uri,
                label: 'URL',
              ),
            ),
            _InfoRow(label: 'Server', value: call.server),
            _InfoRow(label: 'Endpoint', value: call.endpoint),
            _InfoRow(
              label: 'Method',
              valueWidget: MethodBadge(method: call.method),
            ),
            _InfoRow(
              label: 'Status',
              valueWidget: StatusBadge(
                statusText: call.statusText,
                statusCode: call.response?.statusCode,
                isLoading: call.loading,
                isError: call.isError,
              ),
            ),
            _InfoRow(label: 'Secure', value: call.secure ? 'HTTPS ✓' : 'HTTP'),
            _InfoRow(
              label: 'Duration',
              value: CallFormatter.formatDuration(call.duration),
              valueColor: durationColor,
            ),
            _InfoRow(
              label: 'Request Time',
              value: call.request != null
                  ? CallFormatter.formatTime(call.request!.time)
                  : '—',
            ),
            _InfoRow(
              label: 'Response Time',
              value: call.response != null
                  ? CallFormatter.formatTime(call.response!.time)
                  : '—',
            ),
            _InfoRow(
              label: 'Request Size',
              value: CallFormatter.formatBytes(call.request?.size ?? 0),
            ),
            _InfoRow(
              label: 'Response Size',
              value: CallFormatter.formatBytes(call.response?.size ?? 0),
            ),
          ],
        ),

        if (call.error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HawkColors.clientError.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: HawkColors.clientError.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: HawkColors.clientError,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    call.error!.error?.toString() ?? 'Unknown error',
                    style: TextStyle(
                      color: dimColor,
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero card with status and duration
// ---------------------------------------------------------------------------
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.call,
    required this.durationColor,
  });

  final HawkHttpCall call;
  final Color durationColor;

  @override
  Widget build(BuildContext context) {
    final statusColor = call.isError && call.response == null
        ? HawkColors.networkError
        : HawkColors.forStatusCode(call.response?.statusCode);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.15),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _HeroStat(
            label: 'STATUS',
            value: call.statusText,
            color: statusColor,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          _HeroStat(
            label: 'TIME',
            value: CallFormatter.formatDuration(call.duration),
            color: durationColor,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          _HeroStat(
            label: 'SIZE',
            value: CallFormatter.formatBytes(call.response?.size ?? 0),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section card
// ---------------------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row
// ---------------------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueColor,
    this.onCopy,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onLongPress: onCopy,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: valueWidget ??
                  Text(
                    value ?? '—',
                    style: TextStyle(
                      color: valueColor ?? theme.colorScheme.onSurface,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
            ),
            if (onCopy != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:api_hawk/src/ui/theme/hawk_theme.dart';
import 'package:flutter/material.dart';

/// Displays an HTTP status code as a colored chip.
///
/// Colors are semantically mapped:
/// - 🟢 2xx (success) → teal
/// - 🟡 3xx (redirect) → amber
/// - 🔴 4xx (client error) → red
/// - 🟣 5xx (server error) → purple
/// - ⚪ ERR (no response) → grey
/// - 🔵 ... (loading) → blue
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.statusText,
    this.statusCode,
    this.isLoading = false,
    this.isError = false,
  });

  final String statusText;
  final int? statusCode;
  final bool isLoading;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (isLoading) {
      color = HawkColors.loading;
    } else if (isError && statusCode == null) {
      color = HawkColors.networkError;
    } else {
      color = HawkColors.forStatusCode(statusCode);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

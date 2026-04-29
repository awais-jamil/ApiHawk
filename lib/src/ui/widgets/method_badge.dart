import 'package:api_hawk/src/ui/theme/hawk_theme.dart';
import 'package:flutter/material.dart';

/// Displays an HTTP method (GET, POST, etc.) as a colored chip.
class MethodBadge extends StatelessWidget {
  const MethodBadge({
    super.key,
    required this.method,
    this.compact = false,
  });

  final String method;

  /// If true, uses a smaller font and padding (for list items).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = HawkColors.forMethod(method);
    final fontSize = compact ? 10.0 : 12.0;
    final hPad = compact ? 6.0 : 8.0;
    final vPad = compact ? 2.0 : 3.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      constraints: BoxConstraints(minWidth: compact ? 40 : 52),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        method.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

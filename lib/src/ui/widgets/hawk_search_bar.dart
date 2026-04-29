import 'package:flutter/material.dart';

/// Search bar with HTTP method filter chips.
///
/// The [onSearchChanged] callback fires on every keystroke.
/// The [onMethodFilterChanged] fires when a method chip is toggled.
class HawkSearchBar extends StatefulWidget {
  const HawkSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onMethodFilterChanged,
    required this.selectedMethod,
  });

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onMethodFilterChanged;
  final String? selectedMethod;

  @override
  State<HawkSearchBar> createState() => _HawkSearchBarState();
}

class _HawkSearchBarState extends State<HawkSearchBar> {
  final _controller = TextEditingController();

  static const _methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: TextField(
            controller: _controller,
            onChanged: widget.onSearchChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by URL...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Method filter chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _FilterChip(
                label: 'ALL',
                selected: widget.selectedMethod == null,
                onTap: () => widget.onMethodFilterChanged(null),
              ),
              const SizedBox(width: 6),
              for (final method in _methods) ...[
                _FilterChip(
                  label: method,
                  selected: widget.selectedMethod == method,
                  onTap: () => widget.onMethodFilterChanged(
                    widget.selectedMethod == method ? null : method,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

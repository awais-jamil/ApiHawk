import 'dart:convert';

import 'package:api_hawk/src/utils/copy_helper.dart';
import 'package:flutter/material.dart';

/// A collapsible, syntax-highlighted JSON tree viewer.
///
/// Supports Map, List, and primitive values. Objects and arrays
/// can be expanded/collapsed. Long-press any leaf value to copy it.
///
/// Toggle between **Tree** and **Raw** view using [showRaw].
class JsonViewer extends StatelessWidget {
  const JsonViewer({
    super.key,
    required this.data,
    this.initiallyExpanded = true,
  });

  final dynamic data;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'null',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
      );
    }

    if (data is String) {
      // Try to parse as JSON first
      try {
        final parsed = jsonDecode(data as String);
        return _JsonNode(
          keyName: null,
          value: parsed,
          depth: 0,
          initiallyExpanded: initiallyExpanded,
        );
      } catch (_) {
        return _RawTextViewer(text: data as String);
      }
    }

    if (data is Map || data is List) {
      return _JsonNode(
        keyName: null,
        value: data,
        depth: 0,
        initiallyExpanded: initiallyExpanded,
      );
    }

    return _RawTextViewer(text: data.toString());
  }
}

/// Displays raw text with a monospace font and wrapping.
class _RawTextViewer extends StatelessWidget {
  const _RawTextViewer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SelectableText(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recursive JSON node
// ---------------------------------------------------------------------------
class _JsonNode extends StatefulWidget {
  const _JsonNode({
    required this.keyName,
    required this.value,
    required this.depth,
    required this.initiallyExpanded,
  });

  final String? keyName;
  final dynamic value;
  final int depth;
  final bool initiallyExpanded;

  @override
  State<_JsonNode> createState() => _JsonNodeState();
}

class _JsonNodeState extends State<_JsonNode> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    // Auto-collapse after depth 2 for readability
    _expanded = widget.depth < 2 ? widget.initiallyExpanded : false;
  }

  bool get _isExpandable => widget.value is Map || widget.value is List;

  int get _childCount {
    if (widget.value is Map) return (widget.value as Map).length;
    if (widget.value is List) return (widget.value as List).length;
    return 0;
  }

  String get _bracketOpen => widget.value is Map ? '{' : '[';
  String get _bracketClose => widget.value is Map ? '}' : ']';

  @override
  Widget build(BuildContext context) {
    if (_isExpandable) {
      return _buildExpandableNode(context);
    }
    return _buildLeafNode(context);
  }

  Widget _buildExpandableNode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExpandableHeader(
          keyName: widget.keyName,
          bracketOpen: _bracketOpen,
          bracketClose: _bracketClose,
          childCount: _childCount,
          expanded: _expanded,
          depth: widget.depth,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded) _buildChildren(context),
      ],
    );
  }

  Widget _buildChildren(BuildContext context) {
    final children = <Widget>[];

    if (widget.value is Map) {
      final map = widget.value as Map;
      for (final entry in map.entries) {
        children.add(
          _JsonNode(
            keyName: entry.key.toString(),
            value: entry.value,
            depth: widget.depth + 1,
            initiallyExpanded: widget.initiallyExpanded,
          ),
        );
      }
    } else if (widget.value is List) {
      final list = widget.value as List;
      for (int i = 0; i < list.length; i++) {
        children.add(
          _JsonNode(
            keyName: '[$i]',
            value: list[i],
            depth: widget.depth + 1,
            initiallyExpanded: widget.initiallyExpanded,
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: (widget.depth + 1) * 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children,
          _ClosingBracket(
            bracket: _bracketClose,
            depth: widget.depth,
          ),
        ],
      ),
    );
  }

  Widget _buildLeafNode(BuildContext context) {
    return _LeafNode(
      keyName: widget.keyName,
      value: widget.value,
      depth: widget.depth,
    );
  }
}

// ---------------------------------------------------------------------------
// Expandable header line: ▶ "key": { ... } 5 items
// ---------------------------------------------------------------------------
class _ExpandableHeader extends StatelessWidget {
  const _ExpandableHeader({
    required this.keyName,
    required this.bracketOpen,
    required this.bracketClose,
    required this.childCount,
    required this.expanded,
    required this.depth,
    required this.onTap,
  });

  final String? keyName;
  final String bracketOpen;
  final String bracketClose;
  final int childCount;
  final bool expanded;
  final int depth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: depth * 16.0,
          top: 4,
          bottom: 4,
          right: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              expanded ? Icons.expand_more : Icons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 2),
            if (keyName != null) ...[
              Text(
                '"$keyName"',
                style: const TextStyle(
                  color: Color(0xFF79C0FF),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const Text(
                ': ',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
            Text(
              expanded ? bracketOpen : '$bracketOpen...$bracketClose',
              style: const TextStyle(
                color: Colors.grey,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            if (!expanded) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$childCount ${childCount == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leaf node: "key": value
// ---------------------------------------------------------------------------
class _LeafNode extends StatelessWidget {
  const _LeafNode({
    required this.keyName,
    required this.value,
    required this.depth,
  });

  final String? keyName;
  final dynamic value;
  final int depth;

  Color get _valueColor {
    if (value is String) return const Color(0xFFA5D6FF);
    if (value is num) return const Color(0xFFD2A8FF);
    if (value is bool) return const Color(0xFFFF7B72);
    if (value == null) return Colors.grey;
    return Colors.white70;
  }

  String get _displayValue {
    if (value is String) return '"$value"';
    if (value == null) return 'null';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => CopyHelper.copy(
        context: context,
        text: value?.toString() ?? 'null',
        label: keyName ?? 'Value',
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: depth * 16.0 + 20,
          top: 3,
          bottom: 3,
          right: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (keyName != null) ...[
              Flexible(
                flex: 0,
                child: Text(
                  '"$keyName"',
                  style: const TextStyle(
                    color: Color(0xFF79C0FF),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const Text(
                ': ',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
            Flexible(
              child: Text(
                _displayValue,
                style: TextStyle(
                  color: _valueColor,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Closing bracket
// ---------------------------------------------------------------------------
class _ClosingBracket extends StatelessWidget {
  const _ClosingBracket({
    required this.bracket,
    required this.depth,
  });

  final String bracket;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        bracket,
        style: const TextStyle(
          color: Colors.grey,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Wrapper that toggles between Tree and Raw JSON view.
class JsonViewerToggle extends StatefulWidget {
  const JsonViewerToggle({
    super.key,
    required this.data,
    required this.onCopy,
  });

  final dynamic data;
  final VoidCallback onCopy;

  @override
  State<JsonViewerToggle> createState() => _JsonViewerToggleState();
}

class _JsonViewerToggleState extends State<JsonViewerToggle> {
  bool _showRaw = false;

  String get _rawText {
    if (widget.data == null) return 'null';
    if (widget.data is String) {
      try {
        final parsed = jsonDecode(widget.data as String);
        return const JsonEncoder.withIndent('  ').convert(parsed);
      } catch (_) {
        return widget.data as String;
      }
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(widget.data);
    } catch (_) {
      return widget.data.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text(
                'Body',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              _ToggleChip(
                label: 'Tree',
                selected: !_showRaw,
                onTap: () => setState(() => _showRaw = false),
              ),
              const SizedBox(width: 4),
              _ToggleChip(
                label: 'Raw',
                selected: _showRaw,
                onTap: () => setState(() => _showRaw = true),
              ),
              const SizedBox(width: 8),
              _CopyIconButton(onTap: widget.onCopy),
            ],
          ),
        ),
        const Divider(height: 1),
        // Content
        if (_showRaw)
          _RawTextViewer(text: _rawText)
        else
          JsonViewer(data: widget.data),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _CopyIconButton extends StatelessWidget {
  const _CopyIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.copy_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

import 'package:api_hawk/src/core/hawk_store.dart';
import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/ui/screens/hawk_call_detail_screen.dart';
import 'package:api_hawk/src/ui/theme/hawk_theme.dart';
import 'package:api_hawk/src/ui/widgets/call_list_item.dart';
import 'package:api_hawk/src/ui/widgets/hawk_search_bar.dart';
import 'package:flutter/material.dart';

/// Main inspector screen displaying a searchable, filterable list of HTTP calls.
///
/// Uses [StreamBuilder] to reactively update when new calls arrive.
class HawkInspectorScreen extends StatefulWidget {
  const HawkInspectorScreen({super.key, required this.store});

  final HawkStore store;

  @override
  State<HawkInspectorScreen> createState() => _HawkInspectorScreenState();
}

class _HawkInspectorScreenState extends State<HawkInspectorScreen> {
  String _searchQuery = '';
  String? _methodFilter;

  List<HawkHttpCall> _applyFilters(List<HawkHttpCall> calls) {
    var filtered = calls;

    // Method filter
    if (_methodFilter != null) {
      filtered = filtered
          .where(
            (c) => c.method.toUpperCase() == _methodFilter!.toUpperCase(),
          )
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.uri.toLowerCase().contains(query) ||
                c.endpoint.toLowerCase().contains(query) ||
                c.server.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HawkTheme.dark,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🦅 ',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'API Hawk',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            // Call count badge
            StreamBuilder<List<HawkHttpCall>>(
              stream: widget.store.callsStream,
              initialData: widget.store.calls,
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Clear button
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Clear all',
              onPressed: () => _showClearConfirmation(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search + filters
            HawkSearchBar(
              onSearchChanged: (q) => setState(() => _searchQuery = q),
              onMethodFilterChanged: (m) =>
                  setState(() => _methodFilter = m),
              selectedMethod: _methodFilter,
            ),
            const Divider(height: 1),

            // Call list
            Expanded(
              child: StreamBuilder<List<HawkHttpCall>>(
                stream: widget.store.callsStream,
                initialData: widget.store.calls,
                builder: (context, snapshot) {
                  final allCalls = snapshot.data ?? [];
                  final filteredCalls = _applyFilters(allCalls);

                  if (allCalls.isEmpty) {
                    return const _EmptyState();
                  }

                  if (filteredCalls.isEmpty) {
                    return const _NoResultsState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 80),
                    itemCount: filteredCalls.length,
                    itemBuilder: (context, index) {
                      final call = filteredCalls[index];
                      return CallListItem(
                        call: call,
                        onTap: () => _openDetail(context, call),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, HawkHttpCall call) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HawkCallDetailScreen(
          call: call,
          store: widget.store,
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text('Clear All Calls'),
        content: const Text('This will remove all captured HTTP calls.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.store.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: HawkColors.clientError),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty states
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🦅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No calls captured yet',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'HTTP calls will appear here as they happen',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No matching calls',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search or filter',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:api_hawk/src/core/hawk_store.dart';
import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/ui/tabs/error_tab.dart';
import 'package:api_hawk/src/ui/tabs/overview_tab.dart';
import 'package:api_hawk/src/ui/tabs/request_tab.dart';
import 'package:api_hawk/src/ui/tabs/response_tab.dart';
import 'package:api_hawk/src/ui/theme/hawk_theme.dart';
import 'package:api_hawk/src/ui/widgets/copy_action_sheet.dart';
import 'package:api_hawk/src/ui/widgets/method_badge.dart';
import 'package:api_hawk/src/utils/curl_generator.dart';
import 'package:api_hawk/src/utils/copy_helper.dart';
import 'package:flutter/material.dart';

/// Detail screen for a single HTTP call with tabbed view.
///
/// Tabs: Overview, Request, Response, Error.
/// The app bar contains a copy menu button that opens [CopyActionSheet].
class HawkCallDetailScreen extends StatelessWidget {
  const HawkCallDetailScreen({
    super.key,
    required this.call,
    required this.store,
  });

  final HawkHttpCall call;
  final HawkStore store;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HawkTheme.dark,
      child: StreamBuilder<List<HawkHttpCall>>(
        stream: store.callsStream,
        initialData: store.calls,
        builder: (context, _) {
          // Re-read the call from store to get latest data (in case
          // the response arrives while we're viewing details).
          final latestCall = store.findCallById(call.id) ?? call;
          return _DetailScaffold(call: latestCall);
        },
      ),
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.call});

  final HawkHttpCall call;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MethodBadge(method: call.method),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  call.endpoint,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            // Quick cURL copy
            IconButton(
              icon: const Icon(Icons.terminal, size: 20),
              tooltip: 'Copy cURL',
              onPressed: () => CopyHelper.copy(
                context: context,
                text: CurlGenerator.generate(call),
                label: 'cURL command',
              ),
            ),
            // Full copy menu
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: 'Copy options',
              onPressed: () => CopyActionSheet.show(context, call),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outline, size: 18), text: 'Overview'),
              Tab(icon: Icon(Icons.arrow_upward, size: 18), text: 'Request'),
              Tab(
                icon: Icon(Icons.arrow_downward, size: 18),
                text: 'Response',
              ),
              Tab(icon: Icon(Icons.warning_amber, size: 18), text: 'Error'),
            ],
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 11),
          ),
        ),
        body: TabBarView(
          children: [
            OverviewTab(call: call),
            RequestTab(call: call),
            ResponseTab(call: call),
            ErrorTab(call: call),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:api_hawk/src/core/hawk_store.dart';
import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/models/hawk_http_error.dart';
import 'package:api_hawk/src/models/hawk_http_request.dart';
import 'package:api_hawk/src/models/hawk_http_response.dart';
import 'package:http/http.dart' as http;

/// An [http.BaseClient] wrapper that captures all HTTP requests and responses
/// into the [HawkStore] for inspection.
///
/// Works with Dart's standard `http` package. Wraps any existing [http.Client]:
///
/// ```dart
/// import 'package:http/http.dart' as http;
/// import 'package:api_hawk/api_hawk.dart';
///
/// final innerClient = http.Client();
/// final client = HawkHttpClient(innerClient, hawkInspector.store);
///
/// // All requests are now captured:
/// final response = await client.get(Uri.parse('https://api.example.com/data'));
/// ```
///
/// Or use the shorthand via [HawkInspector]:
/// ```dart
/// final client = hawk.httpClient(http.Client());
/// ```
class HawkHttpClient extends http.BaseClient {
  HawkHttpClient(this._inner, this._store);

  final http.Client _inner;
  final HawkStore _store;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final callId = _store.nextId;
    final uri = request.url;

    // Build the call with request data
    final call = HawkHttpCall(callId)
      ..method = request.method
      ..endpoint = uri.path + (uri.hasQuery ? '?${uri.query}' : '')
      ..server = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}'
      ..uri = uri.toString()
      ..secure = uri.scheme == 'https'
      ..loading = true
      ..createdTime = DateTime.now()
      ..request = HawkHttpRequest(
        headers: Map<String, dynamic>.from(request.headers),
        body: _extractRequestBody(request),
        contentType: request.headers['content-type'] ?? '',
        size: request.contentLength ?? 0,
        time: DateTime.now(),
        queryParameters: uri.queryParameters.isNotEmpty
            ? Map<String, dynamic>.from(uri.queryParameters)
            : const {},
      );

    _store.addCall(call);

    try {
      final streamedResponse = await _inner.send(request);

      // Read the full response body so we can capture it
      final bytes = await streamedResponse.stream.toBytes();
      final bodyString = utf8.decode(bytes, allowMalformed: true);

      // Try to parse as JSON for the tree viewer
      dynamic parsedBody;
      try {
        parsedBody = jsonDecode(bodyString);
      } catch (_) {
        parsedBody = bodyString;
      }

      call
        ..loading = false
        ..response = HawkHttpResponse(
          statusCode: streamedResponse.statusCode,
          headers: streamedResponse.headers,
          body: parsedBody,
          size: bytes.length,
          time: DateTime.now(),
        )
        ..duration = DateTime.now().difference(call.createdTime);

      _store.notifyCallUpdated();

      // Return a new StreamedResponse wrapping the already-read bytes
      return http.StreamedResponse(
        Stream<List<int>>.value(bytes),
        streamedResponse.statusCode,
        contentLength: bytes.length,
        request: streamedResponse.request,
        headers: streamedResponse.headers,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        reasonPhrase: streamedResponse.reasonPhrase,
      );
    } catch (e, stack) {
      call
        ..loading = false
        ..error = HawkHttpError(
          error: e.toString(),
          stackTrace: stack,
        )
        ..duration = DateTime.now().difference(call.createdTime);

      _store.notifyCallUpdated();
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }

  /// Extracts the body from different request types.
  dynamic _extractRequestBody(http.BaseRequest request) {
    if (request is http.Request) {
      if (request.body.isEmpty) return null;
      // Try to parse as JSON
      try {
        return jsonDecode(request.body);
      } catch (_) {
        return request.body;
      }
    }
    if (request is http.MultipartRequest) {
      return {
        'fields': request.fields,
        'files': request.files
            .map((f) => '${f.field}: ${f.filename ?? "unnamed"}')
            .toList(),
      };
    }
    return null;
  }
}

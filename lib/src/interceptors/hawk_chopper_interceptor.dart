import 'dart:async';
import 'dart:convert';

import 'package:api_hawk/src/core/hawk_store.dart';
import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/models/hawk_http_error.dart';
import 'package:api_hawk/src/models/hawk_http_request.dart';
import 'package:api_hawk/src/models/hawk_http_response.dart';
import 'package:chopper/chopper.dart' as chopper;

/// Chopper interceptor that captures all HTTP requests and responses
/// into the [HawkStore] for inspection.
///
/// Add to your [ChopperClient]:
///
/// ```dart
/// import 'package:chopper/chopper.dart';
/// import 'package:api_hawk/api_hawk.dart';
///
/// final client = ChopperClient(
///   baseUrl: Uri.parse('https://api.example.com'),
///   interceptors: [
///     hawkInspector.chopperInterceptor,
///   ],
/// );
/// ```
///
/// Compatible with Chopper 8.x+ (uses the modern `Interceptor` interface
/// with the `Chain` pattern).
class HawkChopperInterceptor implements chopper.Interceptor {
  HawkChopperInterceptor(this._store);

  final HawkStore _store;

  /// Internal map of request hashCode → hawk call ID.
  final Map<int, int> _requestCallIds = {};

  @override
  FutureOr<chopper.Response<BodyType>> intercept<BodyType>(
    chopper.Chain<BodyType> chain,
  ) async {
    final request = chain.request;
    final callId = _store.nextId;

    final uri = request.uri;

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
        body: _parseBody(request.body),
        contentType: request.headers['content-type'] ?? '',
        size: _estimateSize(request.body),
        time: DateTime.now(),
        queryParameters: uri.queryParameters.isNotEmpty
            ? Map<String, dynamic>.from(uri.queryParameters)
            : const {},
      );

    _store.addCall(call);
    _requestCallIds[request.hashCode] = callId;

    try {
      final response = await chain.proceed(request);

      // Parse the response body for the inspector
      dynamic parsedBody = response.body;
      if (parsedBody is String) {
        try {
          parsedBody = jsonDecode(parsedBody);
        } catch (_) {
          // Keep as string
        }
      }

      call
        ..loading = false
        ..response = HawkHttpResponse(
          statusCode: response.statusCode,
          headers: response.base.headers,
          body: parsedBody,
          size: _estimateSize(response.body),
          time: DateTime.now(),
        )
        ..duration = DateTime.now().difference(call.createdTime);

      _store.notifyCallUpdated();
      _requestCallIds.remove(request.hashCode);

      return response;
    } catch (e, stack) {
      call
        ..loading = false
        ..error = HawkHttpError(
          error: e.toString(),
          stackTrace: stack,
        )
        ..duration = DateTime.now().difference(call.createdTime);

      // Try to extract response from error if available
      if (e is chopper.Response) {
        call.response = HawkHttpResponse(
          statusCode: e.statusCode,
          headers: e.base.headers,
          body: e.body,
          size: _estimateSize(e.body),
          time: DateTime.now(),
        );
      }

      _store.notifyCallUpdated();
      _requestCallIds.remove(request.hashCode);
      rethrow;
    }
  }

  dynamic _parseBody(dynamic body) {
    if (body == null) return null;
    if (body is String) {
      if (body.isEmpty) return null;
      try {
        return jsonDecode(body);
      } catch (_) {
        return body;
      }
    }
    return body;
  }

  int _estimateSize(dynamic data) {
    if (data == null) return 0;
    if (data is String) return utf8.encode(data).length;
    if (data is List<int>) return data.length;
    try {
      return utf8.encode(jsonEncode(data)).length;
    } catch (_) {
      return utf8.encode(data.toString()).length;
    }
  }
}

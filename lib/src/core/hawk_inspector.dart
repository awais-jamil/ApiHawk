import 'dart:convert';

import 'package:api_hawk/src/core/hawk_store.dart';
import 'package:api_hawk/src/interceptors/hawk_chopper_interceptor.dart';
import 'package:api_hawk/src/interceptors/hawk_dio_interceptor.dart';
import 'package:api_hawk/src/interceptors/hawk_http_client.dart';
import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/models/hawk_http_error.dart';
import 'package:api_hawk/src/models/hawk_http_request.dart';
import 'package:api_hawk/src/models/hawk_http_response.dart';
import 'package:api_hawk/src/ui/screens/hawk_inspector_screen.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Main entry point for the API Hawk inspector.
///
/// Supports **Dio**, **http**, and **Chopper** out of the box, plus a
/// generic logging API for any other HTTP client.
///
/// ### Dio
/// ```dart
/// dio.interceptors.add(hawk.dioInterceptor);
/// ```
///
/// ### http package
/// ```dart
/// final client = hawk.httpClient(http.Client());
/// ```
///
/// ### Chopper
/// ```dart
/// ChopperClient(interceptors: [hawk.chopperInterceptor]);
/// ```
///
/// ### Any other client (generic API)
/// ```dart
/// final id = hawk.logRequest(method: 'GET', url: '...');
/// hawk.logResponse(callId: id, statusCode: 200, body: data);
/// ```
class HawkInspector {
  HawkInspector({
    int maxCalls = 200,
    this.navigatorKey,
  }) : _store = HawkStore(maxCalls: maxCalls);

  /// Optional navigator key for pushing the inspector from overlay contexts.
  final GlobalKey<NavigatorState>? navigatorKey;

  final HawkStore _store;
  late final HawkDioInterceptor _dioInterceptor =
      HawkDioInterceptor(_store);
  late final HawkChopperInterceptor _chopperInterceptor =
      HawkChopperInterceptor(_store);

  // ---------------------------------------------------------------------------
  // Client-specific interceptors
  // ---------------------------------------------------------------------------

  /// Dio interceptor. Add to your [Dio] instance:
  /// ```dart
  /// dio.interceptors.add(hawk.dioInterceptor);
  /// ```
  Interceptor get dioInterceptor => _dioInterceptor;

  /// Wraps an [http.Client] to capture all requests.
  /// ```dart
  /// final client = hawk.httpClient(http.Client());
  /// final response = await client.get(Uri.parse('https://...'));
  /// ```
  HawkHttpClient httpClient(http.Client inner) =>
      HawkHttpClient(inner, _store);

  /// Chopper interceptor. Add to your [ChopperClient]:
  /// ```dart
  /// ChopperClient(interceptors: [hawk.chopperInterceptor]);
  /// ```
  chopper.Interceptor get chopperInterceptor => _chopperInterceptor;

  // ---------------------------------------------------------------------------
  // Generic HTTP client API
  // ---------------------------------------------------------------------------

  /// Logs a request from **any HTTP client**.
  ///
  /// Returns a unique call ID. Pass this ID to [logResponse] or [logError]
  /// when the call completes.
  ///
  /// ```dart
  /// final callId = hawk.logRequest(
  ///   method: 'POST',
  ///   url: 'https://api.example.com/users',
  ///   headers: {'Authorization': 'Bearer token'},
  ///   body: {'name': 'John'},
  /// );
  /// ```
  int logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    String? contentType,
  }) {
    final uri = Uri.parse(url);
    final call = HawkHttpCall(_store.nextId)
      ..method = method.toUpperCase()
      ..endpoint = uri.path
      ..server = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}'
      ..uri = url
      ..secure = uri.scheme == 'https'
      ..loading = true
      ..createdTime = DateTime.now()
      ..request = HawkHttpRequest(
        headers: headers ?? {},
        body: body,
        contentType: contentType ?? '',
        size: _estimateSize(body),
        time: DateTime.now(),
        queryParameters: queryParameters ?? {},
      );

    _store.addCall(call);
    return call.id;
  }

  /// Logs a successful response for a previously logged request.
  ///
  /// ```dart
  /// hawk.logResponse(
  ///   callId: callId,
  ///   statusCode: 200,
  ///   headers: {'content-type': 'application/json'},
  ///   body: {'id': 1, 'name': 'John'},
  /// );
  /// ```
  void logResponse({
    required int callId,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
  }) {
    final call = _store.findCallById(callId);
    if (call == null) return;

    call
      ..loading = false
      ..response = HawkHttpResponse(
        statusCode: statusCode,
        headers: headers ?? {},
        body: body,
        size: _estimateSize(body),
        time: DateTime.now(),
      )
      ..duration = DateTime.now().difference(call.createdTime);

    _store.notifyCallUpdated();
  }

  /// Logs an error for a previously logged request.
  ///
  /// Optionally include a partial response (e.g. for 4xx/5xx errors
  /// that carry a response body).
  ///
  /// ```dart
  /// hawk.logError(
  ///   callId: callId,
  ///   error: 'Connection refused',
  ///   statusCode: 500,
  ///   responseBody: {'error': 'Internal Server Error'},
  /// );
  /// ```
  void logError({
    required int callId,
    required dynamic error,
    StackTrace? stackTrace,
    int? statusCode,
    Map<String, String>? responseHeaders,
    dynamic responseBody,
  }) {
    final call = _store.findCallById(callId);
    if (call == null) return;

    call
      ..loading = false
      ..error = HawkHttpError(
        error: error,
        stackTrace: stackTrace,
      )
      ..duration = DateTime.now().difference(call.createdTime);

    if (statusCode != null) {
      call.response = HawkHttpResponse(
        statusCode: statusCode,
        headers: responseHeaders ?? {},
        body: responseBody,
        size: _estimateSize(responseBody),
        time: DateTime.now(),
      );
    }

    _store.notifyCallUpdated();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  /// The underlying store (for advanced usage — e.g. custom UI, streams).
  HawkStore get store => _store;

  /// Opens the Hawk inspector screen as a full-screen modal route.
  ///
  /// Uses [navigatorKey] if provided, otherwise falls back to
  /// [Navigator.of] with the given [context].
  void show([BuildContext? context]) {
    final navigator = navigatorKey?.currentState ??
        (context != null ? Navigator.of(context) : null);

    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => HawkInspectorScreen(store: _store),
      ),
    );
  }

  /// Returns a [Route] for the inspector screen (for named/declarative routing).
  Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => HawkInspectorScreen(store: _store),
      );

  /// Clears all captured calls.
  void clear() => _store.clear();

  /// Disposes the inspector and releases resources.
  void dispose() => _store.dispose();

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

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

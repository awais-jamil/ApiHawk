import 'dart:convert';

import 'package:api_hawk/src/core/hawk_store.dart';
import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/models/hawk_http_error.dart';
import 'package:api_hawk/src/models/hawk_http_request.dart';
import 'package:api_hawk/src/models/hawk_http_response.dart';
import 'package:dio/dio.dart';

/// Hawk's key for storing the call ID in Dio's [RequestOptions.extra].
const String _kHawkCallIdKey = '_hawk_call_id';

/// Dio interceptor that captures HTTP requests, responses, and errors
/// into the [HawkStore] for inspection.
///
/// Add this interceptor to your Dio instance:
/// ```dart
/// dio.interceptors.add(hawkInspector.dioInterceptor);
/// ```
class HawkDioInterceptor extends Interceptor {
  HawkDioInterceptor(this._store);

  final HawkStore _store;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final call = HawkHttpCall(_store.nextId)
      ..method = options.method
      ..endpoint = options.path
      ..server = options.baseUrl
      ..uri = options.uri.toString()
      ..secure = options.uri.scheme == 'https'
      ..loading = true
      ..createdTime = DateTime.now();

    // Build request model
    if (options.data is FormData) {
      final formData = options.data as FormData;
      call.request = HawkHttpRequest(
        headers: Map<String, dynamic>.from(options.headers),
        body: 'Form Data',
        contentType: options.contentType ?? 'multipart/form-data',
        size: _estimateSize(options.data),
        time: DateTime.now(),
        queryParameters: Map<String, dynamic>.from(options.queryParameters),
        formDataFields: formData.fields.toList(),
        formDataFiles: formData.files
            .map((e) => MapEntry(e.key, e.value.filename ?? 'unknown'))
            .toList(),
      );
    } else {
      call.request = HawkHttpRequest(
        headers: Map<String, dynamic>.from(options.headers),
        body: options.data,
        contentType: options.contentType ?? '',
        size: _estimateSize(options.data),
        time: DateTime.now(),
        queryParameters: Map<String, dynamic>.from(options.queryParameters),
      );
    }

    _store.addCall(call);

    // Tag the request so we can match this call in onResponse/onError.
    options.extra[_kHawkCallIdKey] = call.id;

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final callId = response.requestOptions.extra[_kHawkCallIdKey] as int?;
    if (callId != null) {
      final call = _store.findCallById(callId);
      if (call != null) {
        // Re-read headers from the final requestOptions so that headers
        // added by later interceptors (auth tokens, etc.) are captured.
        call.request?.headers = Map<String, dynamic>.from(
          response.requestOptions.headers,
        );

        call
          ..loading = false
          ..response = HawkHttpResponse(
            statusCode: response.statusCode ?? 0,
            headers: _extractHeaders(response.headers),
            body: response.data,
            size: _estimateSize(response.data),
            time: DateTime.now(),
          )
          ..duration = DateTime.now().difference(call.createdTime);
        _store.notifyCallUpdated();
      }
    }
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final callId = err.requestOptions.extra[_kHawkCallIdKey] as int?;
    if (callId != null) {
      final call = _store.findCallById(callId);
      if (call != null) {
        // Re-read headers from the final requestOptions.
        call.request?.headers = Map<String, dynamic>.from(
          err.requestOptions.headers,
        );

        call
          ..loading = false
          ..error = HawkHttpError(
            error: err.message ?? err.toString(),
            stackTrace: err.stackTrace,
          )
          ..duration = DateTime.now().difference(call.createdTime);

        // Some errors still carry a response (e.g. 4xx, 5xx).
        if (err.response != null) {
          call.response = HawkHttpResponse(
            statusCode: err.response?.statusCode ?? 0,
            headers: _extractHeaders(err.response!.headers),
            body: err.response?.data,
            size: _estimateSize(err.response?.data),
            time: DateTime.now(),
          );
        }

        _store.notifyCallUpdated();
      }
    }
    handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, String> _extractHeaders(Headers headers) {
    final map = <String, String>{};
    headers.forEach((name, values) {
      map[name] = values.join(', ');
    });
    return map;
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

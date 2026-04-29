import 'dart:convert';

import 'package:api_hawk/src/models/hawk_http_call.dart';
import 'package:api_hawk/src/utils/curl_generator.dart';

/// Formats [HawkHttpCall] data into human-readable text for copying/sharing.
class CallFormatter {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Formats a dynamic value (Map, List, String, etc.) as pretty JSON.
  static String formatBody(dynamic body) {
    if (body == null) return 'Empty';
    if (body is String) {
      // Try to parse and re-format JSON strings
      try {
        final parsed = jsonDecode(body);
        return _encoder.convert(parsed);
      } catch (_) {
        return body;
      }
    }
    try {
      return _encoder.convert(body);
    } catch (_) {
      return body.toString();
    }
  }

  /// Formats headers map as a readable string.
  static String formatHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return 'No headers';
    final buffer = StringBuffer();
    headers.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString().trimRight();
  }

  /// Formats the complete request section as text.
  static String formatRequest(HawkHttpCall call) {
    final req = call.request;
    if (req == null) return 'No request data';

    final buffer = StringBuffer()
      ..writeln('--- Request ---')
      ..writeln('URL: ${call.uri}')
      ..writeln('Method: ${call.method}')
      ..writeln('Time: ${req.time.toIso8601String()}')
      ..writeln('Content-Type: ${req.contentType}')
      ..writeln('Size: ${formatBytes(req.size)}')
      ..writeln()
      ..writeln('Headers:')
      ..writeln(formatHeaders(req.headers))
      ..writeln()
      ..writeln('Query Parameters:')
      ..writeln(
        req.queryParameters.isEmpty
            ? 'None'
            : formatHeaders(req.queryParameters),
      )
      ..writeln()
      ..writeln('Body:')
      ..writeln(formatBody(req.body));

    if (req.formDataFields.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Form Fields:');
      for (final field in req.formDataFields) {
        buffer.writeln('  ${field.key}: ${field.value}');
      }
    }
    if (req.formDataFiles.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Form Files:');
      for (final file in req.formDataFiles) {
        buffer.writeln('  ${file.key}: ${file.value}');
      }
    }

    return buffer.toString().trimRight();
  }

  /// Formats the complete response section as text.
  static String formatResponse(HawkHttpCall call) {
    final res = call.response;
    if (res == null) return 'No response data';

    final buffer = StringBuffer()
      ..writeln('--- Response ---')
      ..writeln('Status: ${res.statusCode}')
      ..writeln('Time: ${res.time.toIso8601String()}')
      ..writeln('Size: ${formatBytes(res.size)}')
      ..writeln()
      ..writeln('Headers:')
      ..writeln(formatHeaders(Map<String, dynamic>.from(res.headers)))
      ..writeln()
      ..writeln('Body:')
      ..writeln(formatBody(res.body));

    return buffer.toString().trimRight();
  }

  /// Formats the error section as text.
  static String formatError(HawkHttpCall call) {
    final err = call.error;
    if (err == null) return 'No error';

    final buffer = StringBuffer()
      ..writeln('--- Error ---')
      ..writeln('Error: ${err.error}');
    if (err.stackTrace != null) {
      buffer
        ..writeln()
        ..writeln('Stack Trace:')
        ..writeln(err.stackTrace.toString());
    }

    return buffer.toString().trimRight();
  }

  /// Formats the full call (request + response + error + cURL) as text.
  static String formatFullCall(HawkHttpCall call) {
    final buffer = StringBuffer()
      ..writeln('═══════════════════════════════════════')
      ..writeln('API Hawk — HTTP Call Log')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('═══════════════════════════════════════')
      ..writeln()
      ..writeln('Overview:')
      ..writeln('  Method: ${call.method}')
      ..writeln('  URL: ${call.uri}')
      ..writeln('  Status: ${call.statusText}')
      ..writeln('  Duration: ${formatDuration(call.duration)}')
      ..writeln('  Secure: ${call.secure}')
      ..writeln()
      ..writeln(formatRequest(call))
      ..writeln()
      ..writeln(formatResponse(call));

    if (call.error != null) {
      buffer
        ..writeln()
        ..writeln(formatError(call));
    }

    buffer
      ..writeln()
      ..writeln('--- cURL ---')
      ..writeln(CurlGenerator.generate(call));

    return buffer.toString().trimRight();
  }

  /// Formats bytes into a human-readable string.
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Formats a duration into a human-readable string.
  static String formatDuration(Duration? duration) {
    if (duration == null) return '—';
    final ms = duration.inMilliseconds;
    if (ms < 1000) return '${ms}ms';
    if (ms < 60000) return '${(ms / 1000).toStringAsFixed(1)}s';
    return '${(ms / 60000).toStringAsFixed(1)}m';
  }

  /// Formats a [DateTime] as a time-only string (HH:mm:ss).
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}

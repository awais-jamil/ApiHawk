import 'dart:convert';

import 'package:api_hawk/src/models/hawk_http_call.dart';

/// Generates cURL commands from captured HTTP calls.
class CurlGenerator {
  /// Builds a ready-to-paste cURL command string for the given [call].
  static String generate(HawkHttpCall call) {
    final parts = <String>['curl -X ${call.method}'];

    // Headers
    call.request?.headers.forEach((key, value) {
      final escaped = value.toString().replaceAll("'", "\\'");
      parts.add("-H '$key: $escaped'");
    });

    // Body
    final body = call.request?.body;
    if (body != null && body.toString().isNotEmpty && body != 'Form Data') {
      String bodyStr;
      try {
        bodyStr = body is String ? body : jsonEncode(body);
      } catch (_) {
        bodyStr = body.toString();
      }
      final escaped = bodyStr.replaceAll("'", "\\'");
      parts.add("-d '$escaped'");
    }

    // Form data fields
    final fields = call.request?.formDataFields ?? [];
    for (final field in fields) {
      final escaped = field.value.replaceAll("'", "\\'");
      parts.add("-F '${field.key}=$escaped'");
    }

    // Form data files
    final files = call.request?.formDataFiles ?? [];
    for (final file in files) {
      parts.add("-F '${file.key}=@${file.value}'");
    }

    // URL
    parts.add("'${call.uri}'");

    return parts.join(' \\\n  ');
  }
}

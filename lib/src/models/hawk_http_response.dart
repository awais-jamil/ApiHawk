/// Represents an HTTP response captured by the Hawk interceptor.
class HawkHttpResponse {
  HawkHttpResponse({
    this.statusCode = 0,
    this.headers = const {},
    this.body,
    this.size = 0,
    required this.time,
  });

  /// HTTP status code (e.g. 200, 404, 500).
  final int statusCode;

  /// Response headers.
  final Map<String, String> headers;

  /// Response body (may be Map, List, String, or null).
  final dynamic body;

  /// Estimated size of the response in bytes.
  final int size;

  /// Timestamp when the response was received.
  final DateTime time;
}

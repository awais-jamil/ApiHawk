/// Represents an HTTP request captured by the Hawk interceptor.
class HawkHttpRequest {
  HawkHttpRequest({
    this.headers = const {},
    this.body,
    this.contentType = '',
    this.size = 0,
    required this.time,
    this.queryParameters = const {},
    this.formDataFields = const [],
    this.formDataFiles = const [],
  });

  /// Request headers (mutable — updated in onResponse with final headers).
  Map<String, dynamic> headers;

  /// Request body (may be Map, List, String, FormData, or null).
  final dynamic body;

  /// Content-Type of the request.
  final String contentType;

  /// Estimated size of the request in bytes.
  final int size;

  /// Timestamp when the request was sent.
  final DateTime time;

  /// URL query parameters.
  final Map<String, dynamic> queryParameters;

  /// Form data fields (if request used FormData).
  final List<MapEntry<String, String>> formDataFields;

  /// Form data file names (if request used FormData).
  final List<MapEntry<String, String>> formDataFiles;
}

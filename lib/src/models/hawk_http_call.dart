import 'package:api_hawk/src/models/hawk_http_error.dart';
import 'package:api_hawk/src/models/hawk_http_request.dart';
import 'package:api_hawk/src/models/hawk_http_response.dart';

/// Represents a complete HTTP call lifecycle (request → response/error).
///
/// This is a mutable model — the interceptor creates it with request data
/// and later populates [response] or [error] when the call completes.
class HawkHttpCall {
  HawkHttpCall(this.id);

  /// Unique identifier for this call.
  final int id;

  /// HTTP method (GET, POST, PUT, DELETE, PATCH, etc.).
  String method = '';

  /// Request endpoint/path (e.g. `/api/v1/plans`).
  String endpoint = '';

  /// Server base URL (e.g. `https://api.example.com`).
  String server = '';

  /// Full URI string.
  String uri = '';

  /// Whether the connection used HTTPS.
  bool secure = false;

  /// Whether the call is still in progress.
  bool loading = true;

  /// Time elapsed between request and response.
  Duration? duration;

  /// Timestamp when the call was initiated.
  DateTime createdTime = DateTime.now();

  /// Request data (populated immediately in [onRequest]).
  HawkHttpRequest? request;

  /// Response data (populated in [onResponse] or [onError]).
  HawkHttpResponse? response;

  /// Error data (populated only in [onError]).
  HawkHttpError? error;

  /// Whether the call completed successfully (2xx status).
  bool get isSuccess {
    final code = response?.statusCode ?? 0;
    return code >= 200 && code < 300;
  }

  /// Whether the call resulted in an error.
  bool get isError => error != null;

  /// Human-readable status code display.
  String get statusText {
    if (loading) return '...';
    if (error != null && response == null) return 'ERR';
    return '${response?.statusCode ?? '?'}';
  }

  /// Short display path for list items.
  String get displayPath {
    if (endpoint.isEmpty) return uri;
    return endpoint.length > 60
        ? '...${endpoint.substring(endpoint.length - 57)}'
        : endpoint;
  }
}

/// Represents an HTTP error captured by the Hawk interceptor.
class HawkHttpError {
  HawkHttpError({
    this.error,
    this.stackTrace,
  });

  /// The error object (typically a String message or Exception).
  final dynamic error;

  /// Stack trace associated with the error, if available.
  final StackTrace? stackTrace;
}

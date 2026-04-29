import 'dart:async';

import 'package:api_hawk/src/models/hawk_http_call.dart';

/// In-memory store for captured HTTP calls.
///
/// Maintains a capped list of calls and exposes a broadcast stream
/// for reactive UI updates. Newest calls appear first.
class HawkStore {
  HawkStore({this.maxCalls = 200});

  /// Maximum number of calls to retain. Oldest are pruned when exceeded.
  final int maxCalls;

  int _idCounter = 0;
  final List<HawkHttpCall> _calls = [];
  final StreamController<List<HawkHttpCall>> _controller =
      StreamController<List<HawkHttpCall>>.broadcast();

  /// Generates a unique, incrementing call ID.
  int get nextId => ++_idCounter;

  /// Live stream of the current call list. Emits on every change.
  Stream<List<HawkHttpCall>> get callsStream => _controller.stream;

  /// Current snapshot of all captured calls (newest first).
  List<HawkHttpCall> get calls => List.unmodifiable(_calls);

  /// Adds a new call to the store (inserted at the front).
  void addCall(HawkHttpCall call) {
    if (_calls.length >= maxCalls) {
      _calls.removeLast();
    }
    _calls.insert(0, call);
    _notify();
  }

  /// Notifies listeners that a call has been updated in-place.
  void notifyCallUpdated() {
    _notify();
  }

  /// Finds a call by its unique [id]. Returns `null` if not found.
  HawkHttpCall? findCallById(int id) {
    for (final call in _calls) {
      if (call.id == id) return call;
    }
    return null;
  }

  /// Removes all captured calls.
  void clear() {
    _calls.clear();
    _notify();
  }

  /// Releases the stream controller. Call when the inspector is disposed.
  void dispose() {
    _controller.close();
  }

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_calls));
    }
  }
}

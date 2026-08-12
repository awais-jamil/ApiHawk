import 'package:flutter_test/flutter_test.dart';
import 'package:api_hawk/api_hawk.dart';

void main() {
  group('HawkStore', () {
    late HawkStore store;

    setUp(() {
      store = HawkStore(maxCalls: 3);
    });

    tearDown(() {
      store.dispose();
    });

    test('generates incrementing ids', () {
      expect(store.nextId, 1);
      expect(store.nextId, 2);
      expect(store.nextId, 3);
    });

    test('adds calls and keeps them in reverse order', () {
      final call1 = HawkHttpCall(1);
      final call2 = HawkHttpCall(2);

      store.addCall(call1);
      store.addCall(call2);

      expect(store.calls.length, 2);
      expect(store.calls.first.id, 2);
      expect(store.calls.last.id, 1);
    });

    test('respects maxCalls limit by removing oldest calls', () {
      store.addCall(HawkHttpCall(1));
      store.addCall(HawkHttpCall(2));
      store.addCall(HawkHttpCall(3));
      store.addCall(HawkHttpCall(4));

      expect(store.calls.length, 3);
      expect(store.calls.first.id, 4);
      expect(store.calls.last.id, 2);
    });

    test('finds call by id', () {
      final call1 = HawkHttpCall(1);
      store.addCall(call1);

      expect(store.findCallById(1), isNotNull);
      expect(store.findCallById(2), isNull);
    });

    test('clears all calls', () {
      store.addCall(HawkHttpCall(1));
      store.clear();

      expect(store.calls, isEmpty);
    });

    test('emits stream updates', () async {
      final call1 = HawkHttpCall(1);

      expectLater(
        store.callsStream,
        emitsInOrder([
          [call1]
        ]),
      );

      store.addCall(call1);
    });
  });
}

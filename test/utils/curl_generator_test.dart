import 'package:flutter_test/flutter_test.dart';
import 'package:api_hawk/api_hawk.dart';

void main() {
  group('CurlGenerator', () {
    test('generates basic GET curl', () {
      final call = HawkHttpCall(1)
        ..method = 'GET'
        ..uri = 'https://api.example.com/users'
        ..request = HawkHttpRequest(
          time: DateTime.now(),
          headers: {'Authorization': 'Bearer token123'},
        );

      final curl = CurlGenerator.generate(call);

      expect(curl, contains("curl -X GET"));
      expect(curl, contains("-H 'Authorization: Bearer token123'"));
      expect(curl, contains("'https://api.example.com/users'"));
    });

    test('generates POST curl with JSON body', () {
      final call = HawkHttpCall(2)
        ..method = 'POST'
        ..uri = 'https://api.example.com/users'
        ..request = HawkHttpRequest(
          time: DateTime.now(),
          headers: {'Content-Type': 'application/json'},
          body: {'name': 'John'},
        );

      final curl = CurlGenerator.generate(call);

      expect(curl, contains("curl -X POST"));
      expect(curl, contains("-H 'Content-Type: application/json'"));
      expect(curl, contains("-d '{\"name\":\"John\"}'"));
    });
  });
}

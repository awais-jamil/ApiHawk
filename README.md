# API Hawk

A lightweight HTTP inspector for Flutter with built-in support for Dio, http, and Chopper.

Capture, search, and inspect network calls with a clean dark UI. Copy exactly what you need — a URL, just the response body, headers, or a ready-to-paste cURL command.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Why?

Most inspector packages are either unmaintained ([flutter_alice](https://pub.dev/packages/flutter_alice)), too heavy on dependencies ([chucker_flutter](https://pub.dev/packages/chucker_flutter)), or lock you into a single HTTP client.

API Hawk works with the three most popular Flutter HTTP clients out of the box, stays in memory (no database, no disk writes), and lets you copy individual parts of a request instead of dumping everything at once.

## Installation

```yaml
dependencies:
  api_hawk:
    git:
      url: https://github.com/awais-jamil/ApiHawk.git
```

## Setup

Create one instance and share it across your app.

```dart
import 'package:api_hawk/api_hawk.dart';

final hawk = HawkInspector();
```

---

## Dio

Add the interceptor to your Dio instance. Every request made through that instance gets captured automatically.

```dart
import 'package:api_hawk/api_hawk.dart';
import 'package:dio/dio.dart';

final hawk = HawkInspector();
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
  ..interceptors.add(hawk.dioInterceptor);
```

Making requests — nothing changes in your existing code:

```dart
// GET
final users = await dio.get('/users');

// GET with query parameters
final filtered = await dio.get('/users', queryParameters: {'role': 'admin', 'page': '1'});

// POST with JSON body
final created = await dio.post('/users', data: {
  'name': 'John Doe',
  'email': 'john@example.com',
});

// PUT
await dio.put('/users/42', data: {'name': 'Jane Doe'});

// DELETE
await dio.delete('/users/42');

// Multipart upload
final formData = FormData.fromMap({
  'avatar': await MultipartFile.fromFile('/path/to/image.jpg'),
  'name': 'profile_pic',
});
await dio.post('/upload', data: formData);
```

Errors are captured too — if a request returns 4xx/5xx or the connection fails, it shows up in the inspector with the error details and stack trace.

---

## http package

Wrap your `http.Client` with `hawk.httpClient()`. The returned client has the exact same API — just swap it in.

```dart
import 'package:api_hawk/api_hawk.dart';
import 'package:http/http.dart' as http;

final hawk = HawkInspector();
final client = hawk.httpClient(http.Client());
```

Use it like you normally would:

```dart
// GET
final response = await client.get(
  Uri.parse('https://api.example.com/users'),
  headers: {'Authorization': 'Bearer $token'},
);

// POST with JSON
final created = await client.post(
  Uri.parse('https://api.example.com/users'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'name': 'John', 'email': 'john@example.com'}),
);

// Multipart
final request = http.MultipartRequest('POST', Uri.parse('https://api.example.com/upload'));
request.files.add(await http.MultipartFile.fromPath('file', '/path/to/image.jpg'));
request.fields['description'] = 'Profile photo';
final streamedResponse = await client.send(request);
```

The response body is automatically parsed as JSON when possible, so it shows up in the tree viewer.

---

## Chopper

Pass the interceptor to your `ChopperClient`. Works with Chopper 8.x and the modern `Interceptor` interface.

```dart
import 'package:api_hawk/api_hawk.dart';
import 'package:chopper/chopper.dart';

final hawk = HawkInspector();

final chopperClient = ChopperClient(
  baseUrl: Uri.parse('https://api.example.com'),
  services: [
    UserService.create(),
    PostService.create(),
  ],
  interceptors: [
    hawk.chopperInterceptor,
    // your other interceptors still work
    HttpLoggingInterceptor(),
  ],
  converter: JsonConverter(),
);
```

All requests made through any Chopper service attached to this client will be captured.

```dart
final userService = chopperClient.getService<UserService>();
final response = await userService.getUser(id: 42);
final allUsers = await userService.getUsers(page: 1);
```

---

## Retrofit

Retrofit generates code on top of Dio, so the Dio interceptor covers it. No extra setup needed.

```dart
import 'package:api_hawk/api_hawk.dart';
import 'package:dio/dio.dart';

final hawk = HawkInspector();
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
  ..interceptors.add(hawk.dioInterceptor);

final apiClient = RestClient(dio);

// these are all captured
final user = await apiClient.getUser(42);
final posts = await apiClient.getPosts(page: 1, limit: 20);
await apiClient.createPost(title: 'Hello', body: 'World');
```

---

## Other HTTP Clients

For clients that don't have a built-in interceptor, use the generic logging API. You get a call ID when you log the request, then pass it back when the response (or error) arrives.

```dart
import 'package:api_hawk/api_hawk.dart';

final hawk = HawkInspector();

Future<MyResponse> fetchData() async {
  final callId = hawk.logRequest(
    method: 'GET',
    url: 'https://api.example.com/data',
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
    queryParameters: {'page': '1', 'limit': '20'},
  );

  try {
    // make the request with whatever client you're using
    final response = await myCustomClient.get('/data');

    hawk.logResponse(
      callId: callId,
      statusCode: response.statusCode,
      headers: response.headers,
      body: response.parsedBody,
    );

    return response;
  } catch (e, stack) {
    hawk.logError(
      callId: callId,
      error: e,
      stackTrace: stack,
      statusCode: e is HttpException ? e.statusCode : null,
      responseBody: e is HttpException ? e.body : null,
    );
    rethrow;
  }
}
```

This works with GraphQL clients, gRPC, WebSocket wrappers, or anything that makes HTTP calls.

---

## Opening the Inspector

```dart
// push as a full-screen route
hawk.show(context);

// or get a Route for your own navigation setup
Navigator.of(context).push(hawk.route());
```

The inspector screen shows all captured calls in reverse chronological order. You can search by URL and filter by HTTP method using the chips at the top.

Tap any call to see the detail screen with four tabs: Overview, Request, Response, and Error.

---

## Copying

This is the main reason this package exists. Tap the menu button on any call detail screen and pick exactly what you want:

- **Copy URL** — just the URL
- **Copy Request Headers** — request headers as text
- **Copy Request Body** — formatted JSON
- **Copy Response Headers** — response headers as text
- **Copy Response Body** — formatted JSON
- **Copy as cURL** — a full cURL command you can paste into a terminal
- **Copy Full Call Log** — everything in one block

You can also long-press any header row or any value in the JSON tree to copy just that piece.

There's a dedicated cURL button in the app bar for quick access — no need to open the menu for the most common action.

---

## JSON Viewer

Response and request bodies are displayed as a collapsible tree with syntax highlighting. Keys, strings, numbers, booleans, and nulls each have their own color. You can switch between tree view and raw JSON with a toggle.

Nodes deeper than level 2 are collapsed by default to keep things readable. Tap any node to expand or collapse it.

---

## Configuration

```dart
// keep more calls in memory (default is 200)
final hawk = HawkInspector(maxCalls: 1000);

// clear all captured calls
hawk.clear();

// listen to the call stream for custom logging or UI
hawk.store.callsStream.listen((calls) {
  debugPrint('${calls.length} calls captured');
});

// clean up when you're done
hawk.dispose();
```

---

## Supported Clients

| Client | Integration |
|---|---|
| Dio 5.x | `hawk.dioInterceptor` |
| http 1.x | `hawk.httpClient(inner)` |
| Chopper 8.x | `hawk.chopperInterceptor` |
| Retrofit | via Dio interceptor |
| GraphQL (dio-based) | via Dio interceptor |
| Anything else | `logRequest` / `logResponse` / `logError` |

## Contributing

Pull requests are welcome. If you find a bug or want to add support for another HTTP client, feel free to open an issue or submit a PR.

1. Fork the repository
2. Create your branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

MIT — see [LICENSE](LICENSE) for details.

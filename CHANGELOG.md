## 1.0.3

- Fix: JSON tree viewer horizontal overflow on deeply nested objects — now scrollable sideways
- Fix: Dio interceptor now captures final request headers (auth tokens added by later interceptors)
- Fix: Console logging uses `dart:io` stdout to bypass `runZonedGuarded` zones
- Fix: Console log runs before clipboard (prevents silent failure on iOS simulator)
- Made `HawkHttpRequest.headers` mutable for post-request header updates

## 1.0.1

- Fix: Clipboard doesn't sync on iOS simulator — copied text is now logged to the debug console
- Added "VIEW" action on copy snackbar (debug mode only) to show selectable text in a dialog

## 1.0.0

- Initial release
- Built-in interceptors for Dio, http, and Chopper
- Generic logging API for any HTTP client (`logRequest` / `logResponse` / `logError`)
- Collapsible JSON tree viewer with syntax highlighting
- Granular copy menu: URL, request headers, request body, response headers, response body, cURL, full call log
- Long-press to copy any header row or JSON value
- Quick cURL copy button in app bar
- Search by URL with HTTP method filter chips
- GitHub-dark themed UI
- Optional `navigatorKey` for overlay-safe navigation
- In-memory only storage — no disk writes

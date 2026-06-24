## 1.0.4

- Fix: Snackbar/toast no longer persists when navigating away from API Hawk screens (scoped ScaffoldMessenger)
- Fix: VIEW button crash on stale context — added mounted guard before showing dialog
- Fix: Copy action sheet now correctly shows snackbar on the detail screen after bottom sheet dismissal
- Fix: Console log now uses `dart:developer` log alongside `stdout` for Android Studio Run tab visibility
- UI: Failed API calls (4xx, 5xx, network errors) now show red/purple-tinted card backgrounds with colored borders
- UI: Small error/wifi-off icon added to failed call list items for visual clarity
- Hidden `content-length` from request headers tab (redundant noise)
- Updated README with pub.dev installation, features list, and debug console documentation

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

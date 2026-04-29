import 'package:flutter/material.dart';

/// Color constants and helpers for the Hawk inspector UI.
///
/// The inspector adapts to the host app's [ThemeData] but uses these
/// semantic colors for status codes, HTTP methods, and accents.
class HawkColors {
  const HawkColors._();

  // --- Status code colors ---
  static const Color success = Color(0xFF00BFA6); // 2xx — teal green
  static const Color redirect = Color(0xFFFFB74D); // 3xx — amber
  static const Color clientError = Color(0xFFEF5350); // 4xx — red
  static const Color serverError = Color(0xFF9C27B0); // 5xx — purple
  static const Color networkError = Color(0xFF757575); // no response — grey
  static const Color loading = Color(0xFF42A5F5); // in progress — blue

  // --- HTTP method colors ---
  static const Color methodGet = Color(0xFF42A5F5); // blue
  static const Color methodPost = Color(0xFF66BB6A); // green
  static const Color methodPut = Color(0xFFFFB74D); // amber
  static const Color methodPatch = Color(0xFF9C27B0); // purple
  static const Color methodDelete = Color(0xFFEF5350); // red
  static const Color methodOther = Color(0xFF78909C); // blue-grey

  // --- Duration thresholds ---
  static const Color durationFast = Color(0xFF00BFA6); // < 300ms
  static const Color durationMedium = Color(0xFFFFB74D); // 300ms–1s
  static const Color durationSlow = Color(0xFFEF5350); // > 1s

  /// Returns the appropriate color for an HTTP status code.
  static Color forStatusCode(int? statusCode) {
    if (statusCode == null || statusCode == 0) return networkError;
    if (statusCode >= 200 && statusCode < 300) return success;
    if (statusCode >= 300 && statusCode < 400) return redirect;
    if (statusCode >= 400 && statusCode < 500) return clientError;
    if (statusCode >= 500) return serverError;
    return networkError;
  }

  /// Returns the appropriate color for an HTTP method string.
  static Color forMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return methodGet;
      case 'POST':
        return methodPost;
      case 'PUT':
        return methodPut;
      case 'PATCH':
        return methodPatch;
      case 'DELETE':
        return methodDelete;
      default:
        return methodOther;
    }
  }

  /// Returns the appropriate color for a request duration.
  static Color forDuration(Duration? duration) {
    if (duration == null) return loading;
    final ms = duration.inMilliseconds;
    if (ms < 300) return durationFast;
    if (ms < 1000) return durationMedium;
    return durationSlow;
  }
}

/// The dark [ThemeData] used by the Hawk inspector screens.
///
/// This ensures the inspector always looks consistent regardless of the
/// host app's theme. Uses a deep navy palette with vibrant accents.
class HawkTheme {
  const HawkTheme._();

  static const Color _background = Color(0xFF0D1117);
  static const Color _surface = Color(0xFF161B22);
  static const Color _surfaceVariant = Color(0xFF21262D);
  static const Color _onSurface = Color(0xFFE6EDF3);
  static const Color _onSurfaceDim = Color(0xFF8B949E);
  static const Color _primary = Color(0xFF58A6FF);
  static const Color _divider = Color(0xFF30363D);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        appBarTheme: const AppBarTheme(
          backgroundColor: _surface,
          foregroundColor: _onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          color: _surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _divider, width: 0.5),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        dividerColor: _divider,
        colorScheme: const ColorScheme.dark(
          surface: _surface,
          primary: _primary,
          onSurface: _onSurface,
          onSurfaceVariant: _onSurfaceDim,
          surfaceContainerHighest: _surfaceVariant,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: _primary,
          unselectedLabelColor: _onSurfaceDim,
          indicatorColor: _primary,
          dividerColor: _divider,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _surfaceVariant,
          contentTextStyle: const TextStyle(color: _onSurface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _surfaceVariant,
          selectedColor: _primary.withValues(alpha: 0.2),
          labelStyle: const TextStyle(color: _onSurface, fontSize: 12),
          side: const BorderSide(color: _divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: _onSurface, fontSize: 14),
          bodySmall: TextStyle(color: _onSurfaceDim, fontSize: 12),
          titleMedium: TextStyle(
            color: _onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: TextStyle(color: _onSurfaceDim, fontSize: 11),
        ),
      );
}

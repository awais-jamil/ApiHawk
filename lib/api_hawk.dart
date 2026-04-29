/// API Hawk — A beautiful, lightweight HTTP inspector for Flutter.
///
/// Add the Dio interceptor and open the inspector UI:
/// ```dart
/// final hawk = HawkInspector();
/// dio.interceptors.add(hawk.dioInterceptor);
/// hawk.show(context);
/// ```

// Core
export 'package:api_hawk/src/core/hawk_inspector.dart';
export 'package:api_hawk/src/core/hawk_store.dart';

// Interceptors
export 'package:api_hawk/src/interceptors/hawk_chopper_interceptor.dart';
export 'package:api_hawk/src/interceptors/hawk_dio_interceptor.dart';
export 'package:api_hawk/src/interceptors/hawk_http_client.dart';

// Models
export 'package:api_hawk/src/models/hawk_http_call.dart';
export 'package:api_hawk/src/models/hawk_http_error.dart';
export 'package:api_hawk/src/models/hawk_http_request.dart';
export 'package:api_hawk/src/models/hawk_http_response.dart';

// UI — screens (for direct navigation)
export 'package:api_hawk/src/ui/screens/hawk_call_detail_screen.dart';
export 'package:api_hawk/src/ui/screens/hawk_inspector_screen.dart';

// UI — theme (for customization)
export 'package:api_hawk/src/ui/theme/hawk_theme.dart';

// Utilities (for advanced usage)
export 'package:api_hawk/src/utils/call_formatter.dart';
export 'package:api_hawk/src/utils/copy_helper.dart';
export 'package:api_hawk/src/utils/curl_generator.dart';

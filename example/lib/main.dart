import 'package:api_hawk/api_hawk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 1. Create a single HawkInspector instance for your app.
// ---------------------------------------------------------------------------
final hawk = HawkInspector(maxCalls: 500);

// ---------------------------------------------------------------------------
// 2. Attach the Dio interceptor.
// ---------------------------------------------------------------------------
final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'))
  ..interceptors.add(hawk.dioInterceptor);

void main() => runApp(const ApiHawkExampleApp());

class ApiHawkExampleApp extends StatelessWidget {
  const ApiHawkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Hawk Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF58A6FF),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦅 API Hawk — Example'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(text: 'Dio (Built-in Interceptor)'),
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.download,
              label: 'GET /posts',
              color: HawkColors.methodGet,
              onTap: () => _makeRequest(
                context,
                () => dio.get<dynamic>('/posts'),
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.download,
              label: 'GET /posts/1',
              color: HawkColors.methodGet,
              onTap: () => _makeRequest(
                context,
                () => dio.get<dynamic>('/posts/1'),
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.upload,
              label: 'POST /posts',
              color: HawkColors.methodPost,
              onTap: () => _makeRequest(
                context,
                () => dio.post<dynamic>(
                  '/posts',
                  data: {
                    'title': 'API Hawk Test',
                    'body': 'Testing the HTTP inspector',
                    'userId': 1,
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.edit,
              label: 'PUT /posts/1',
              color: HawkColors.methodPut,
              onTap: () => _makeRequest(
                context,
                () => dio.put<dynamic>(
                  '/posts/1',
                  data: {'title': 'Updated Title', 'body': 'Updated body'},
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.delete,
              label: 'DELETE /posts/1',
              color: HawkColors.methodDelete,
              onTap: () => _makeRequest(
                context,
                () => dio.delete<dynamic>('/posts/1'),
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.error_outline,
              label: 'GET /404-not-found (error)',
              color: HawkColors.clientError,
              onTap: () => _makeRequest(
                context,
                () => dio.get<dynamic>('/this-does-not-exist-404'),
              ),
            ),

            const SizedBox(height: 24),
            const _SectionTitle(text: 'Generic API (Any HTTP Client)'),
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.code,
              label: 'Log a manual GET call',
              color: HawkColors.methodOther,
              onTap: () => _logManualCall(context),
            ),

            const Spacer(),

            // 3. Open the inspector UI
            FilledButton.icon(
              onPressed: () => hawk.show(context),
              icon: const Text('🦅', style: TextStyle(fontSize: 18)),
              label: const Text(
                'Open API Hawk Inspector',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Makes a Dio request and shows result/error in a snackbar.
Future<void> _makeRequest(
  BuildContext context,
  Future<Response<dynamic>> Function() request,
) async {
  try {
    final response = await request();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${response.statusCode} — Success'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Error — ${e.toString().substring(0, 60)}...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Demonstrates the generic logging API for non-Dio clients.
void _logManualCall(BuildContext context) {
  // Step 1: Log the request (returns a call ID)
  final callId = hawk.logRequest(
    method: 'GET',
    url: 'https://custom-api.example.com/users?page=1',
    headers: {
      'Authorization': 'Bearer test-token',
      'Accept': 'application/json',
    },
    queryParameters: {'page': '1'},
  );

  // Step 2: Simulate a delayed response
  Future<void>.delayed(const Duration(milliseconds: 350), () {
    hawk.logResponse(
      callId: callId,
      statusCode: 200,
      headers: {
        'content-type': 'application/json',
        'x-request-id': 'abc-123-def',
      },
      body: {
        'users': [
          {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
          {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
        ],
        'pagination': {
          'page': 1,
          'totalPages': 5,
          'totalItems': 42,
        },
      },
    );
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('📝 Manual call logged — check the inspector'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}

// ---------------------------------------------------------------------------
// UI Components
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

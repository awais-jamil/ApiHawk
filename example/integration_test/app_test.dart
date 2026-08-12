import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:api_hawk_example/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('take screenshots', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Tap Generate Data for Screenshots
    await tester.tap(find.text('Generate Data for Screenshots'));
    await tester.pumpAndSettle();

    // Tap Open API Hawk Inspector
    await tester.tap(find.text('Open API Hawk Inspector'));
    await tester.pumpAndSettle();

    // Small delay to ensure render is complete
    await Future<void>.delayed(const Duration(seconds: 1));
    await binding.takeScreenshot('list_view_1');

    // Tap the specific list item
    await tester.tap(find.text('/v1/catalog/items/fetch?activeOnly=false').first);
    await tester.pumpAndSettle();

    await Future<void>.delayed(const Duration(seconds: 1));
    await binding.takeScreenshot('detail_overview');

    // Swipe left to Request tab using screen coordinates
    await tester.dragFrom(const Offset(300, 400), const Offset(-300, 0));
    await tester.pumpAndSettle();
    
    await Future<void>.delayed(const Duration(seconds: 1));
    await binding.takeScreenshot('detail_request');

    // Swipe left to Response tab
    await tester.dragFrom(const Offset(300, 400), const Offset(-300, 0));
    await tester.pumpAndSettle();
    
    await Future<void>.delayed(const Duration(seconds: 1));
    await binding.takeScreenshot('detail_response');
  });
}

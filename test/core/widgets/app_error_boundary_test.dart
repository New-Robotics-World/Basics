import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/widgets/app_error_boundary.dart';

void main() {
  group('AppErrorBoundary Tests', () {
    testWidgets('Renders friendly crash screen with restart action', (
      tester,
    ) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Simulated render pipeline failure'),
      );

      await tester.pumpWidget(
        MaterialApp(home: AppErrorBoundary(errorDetails: errorDetails)),
      );

      expect(find.text('Something unexpected happened'), findsOneWidget);
      expect(find.text('Restart App'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}

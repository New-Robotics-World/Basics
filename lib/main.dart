import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/widgets/app_error_boundary.dart';
import 'package:taskflow/features/tasks/data/shared_preferences_task_repository.dart';
import 'package:taskflow/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskflow/features/tasks/presentation/screens/task_list_screen.dart';

void main() async {
  // 1. Ensure Flutter engine bindings are initialized for native platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Production Crash Handlers
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // In production, forward to Sentry / Firebase Crashlytics here
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught Async Error: $error');
    return true; // Mark as handled to prevent process crash
  };

  // 3. Intercept widget build errors with clean Material 3 ErrorBoundary
  ErrorWidget.builder = (details) => AppErrorBoundary(errorDetails: details);

  // 4. Initialize durable local disk storage (SharedPreferences)
  final prefs = await SharedPreferences.getInstance();
  final taskRepository = SharedPreferencesTaskRepository(prefs);

  // 5. Launch app with persistent repository injected into Riverpod
  runApp(
    ProviderScope(
      overrides: [taskRepositoryProvider.overrideWithValue(taskRepository)],
      child: const TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow - Modern Task Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern Indigo
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TaskListScreen(),
    );
  }
}

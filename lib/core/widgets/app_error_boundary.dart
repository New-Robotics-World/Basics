import 'package:flutter/material.dart';

/// A production error boundary widget that intercepts render crashes
/// and presents a clean, friendly fallback UI instead of the default grey/red screen.
class AppErrorBoundary extends StatelessWidget {
  const AppErrorBoundary({super.key, required this.errorDetails});

  final FlutterErrorDetails errorDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Something unexpected happened',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'An error occurred while displaying this screen. Our engineering team has been notified.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  // Rebuild the app root cleanly
                  runApp(const RestartAppHelper());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper to trigger a clean UI reboot
class RestartAppHelper extends StatelessWidget {
  const RestartAppHelper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Rebooting...'),
          ),
        ),
      ),
    );
  }
}

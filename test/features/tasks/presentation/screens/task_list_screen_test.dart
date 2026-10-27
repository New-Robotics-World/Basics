import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskflow/features/tasks/presentation/screens/task_list_screen.dart';

void main() {
  group('TaskListScreen Integration & Filter Widget Tests', () {
    late InMemoryTaskRepository fakeRepository;

    const task1 = Task(
      id: 't-1',
      title: 'Buy Groceries',
      priority: TaskPriority.low,
      isCompleted: false,
    );

    const task2 = Task(
      id: 't-2',
      title: 'Deploy Production Release',
      priority: TaskPriority.high,
      isCompleted: true,
    );

    setUp(() {
      fakeRepository = InMemoryTaskRepository(initialTasks: [task1, task2]);
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(fakeRepository)],
        child: const MaterialApp(home: TaskListScreen()),
      );
    }

    testWidgets('Renders all initial tasks on screen', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Buy Groceries'), findsOneWidget);
      expect(find.text('Deploy Production Release'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('Search input filters tasks dynamically', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField).first, 'Groceries');
      await tester.pumpAndSettle();

      // Only matching task remains
      expect(find.text('Buy Groceries'), findsOneWidget);
      expect(find.text('Deploy Production Release'), findsNothing);
    });

    testWidgets('Active and Done filter buttons switch visible tasks', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap 'Active' tab
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();

      expect(find.text('Buy Groceries'), findsOneWidget);
      expect(find.text('Deploy Production Release'), findsNothing);

      // Tap 'Done' tab
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Buy Groceries'), findsNothing);
      expect(find.text('Deploy Production Release'), findsOneWidget);
    });
  });
}

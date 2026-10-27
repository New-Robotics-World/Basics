import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_form_dialog.dart';

void main() {
  group('TaskFormDialog Widget Tests', () {
    testWidgets('Validates empty title input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TaskFormDialog())),
      );

      // Tap Create Task with empty fields
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Expect validation error message
      expect(find.text('Please enter a task title'), findsOneWidget);
    });

    testWidgets('Fills form, submits, and returns valid Task', (tester) async {
      Task? returnedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    returnedTask = await showDialog<Task>(
                      context: context,
                      builder: (_) => const TaskFormDialog(),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open Dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Enter title
      await tester.enterText(
        find.byType(TextFormField).first,
        'Master Flutter Testing',
      );

      // Tap Create Task
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Verify dialog closed and valid Task returned
      expect(returnedTask, isNotNull);
      expect(returnedTask?.title, 'Master Flutter Testing');
      expect(returnedTask?.priority, TaskPriority.medium);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_item_tile.dart';
import 'package:taskflow/main.dart';

void main() {
  group('TaskFlow Smoke and Widget Tests', () {
    testWidgets('App renders task list title and initial tasks', (
      tester,
    ) async {
      await tester.pumpWidget(const TaskFlowApp());
      await tester.pumpAndSettle();

      expect(find.text('TaskFlow'), findsOneWidget);
      expect(find.text('Explore Flutter Project Architecture'), findsOneWidget);
      expect(find.text('Practice Immutable State in Dart'), findsOneWidget);
      expect(find.text('New Task'), findsOneWidget);
    });

    testWidgets('TaskItemTile triggers callbacks on user interaction', (
      tester,
    ) async {
      bool toggled = false;
      bool deleted = false;

      final task = Task(
        id: '99',
        title: 'Review PR',
        priority: TaskPriority.high,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemTile(
              task: task,
              onToggle: (val) => toggled = val,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Verify title and priority rendered
      expect(find.text('Review PR'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);

      // Tap Checkbox
      await tester.tap(find.byType(Checkbox));
      expect(toggled, isTrue);

      // Tap Delete IconButton
      await tester.tap(find.byTooltip('Delete task'));
      expect(deleted, isTrue);
    });
  });
}

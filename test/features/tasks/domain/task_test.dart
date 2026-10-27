import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/domain/task.dart';

void main() {
  group('Task Domain Model Tests', () {
    test('Task is initialized with correct defaults', () {
      const task = Task(id: '1', title: 'Learn Flutter Architecture');

      expect(task.id, '1');
      expect(task.title, 'Learn Flutter Architecture');
      expect(task.description, '');
      expect(task.dueDate, isNull);
      expect(task.priority, TaskPriority.medium);
      expect(task.isCompleted, isFalse);
    });

    test('copyWith updates specified fields while keeping original values', () {
      const task = Task(
        id: '1',
        title: 'Initial Title',
        priority: TaskPriority.low,
      );

      final updated = task.copyWith(title: 'Updated Title', isCompleted: true);

      // Changed fields
      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, isTrue);

      // Unchanged fields preserved
      expect(updated.id, task.id);
      expect(updated.priority, task.priority);
      expect(updated.description, task.description);
    });

    test('value equality holds for identical task contents', () {
      final date = DateTime(2026, 10, 16);
      final taskA = Task(
        id: '1',
        title: 'Test',
        dueDate: date,
        priority: TaskPriority.high,
      );
      final taskB = Task(
        id: '1',
        title: 'Test',
        dueDate: date,
        priority: TaskPriority.high,
      );

      expect(taskA, equals(taskB));
      expect(taskA.hashCode, equals(taskB.hashCode));
    });

    test('toJson and fromJson correctly serialize and deserialize Task', () {
      final date = DateTime(2026, 10, 24, 12, 0);
      final original = Task(
        id: 'json-1',
        title: 'Serialization Test',
        description: 'Testing JSON round-trip',
        dueDate: date,
        priority: TaskPriority.high,
        isCompleted: true,
      );

      final json = original.toJson();
      final reconstructed = Task.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.id, 'json-1');
      expect(reconstructed.priority, TaskPriority.high);
      expect(reconstructed.isCompleted, isTrue);
      expect(reconstructed.dueDate, equals(date));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';

void main() {
  group('InMemoryTaskRepository Tests', () {
    late InMemoryTaskRepository repository;

    final testTask1 = Task(
      id: 'task-1',
      title: 'First Test Task',
      description: 'Description 1',
      priority: TaskPriority.low,
    );

    final testTask2 = Task(
      id: 'task-2',
      title: 'Second Test Task',
      description: 'Description 2',
      priority: TaskPriority.high,
      isCompleted: true,
    );

    setUp(() {
      repository = InMemoryTaskRepository(
        initialTasks: [testTask1, testTask2],
      );
    });

    test('getTasks returns all initial tasks', () async {
      final tasks = await repository.getTasks();

      expect(tasks.length, 2);
      expect(tasks[0], equals(testTask1));
      expect(tasks[1], equals(testTask2));
    });

    test('getTaskById returns correct task when found', () async {
      final task = await repository.getTaskById('task-1');

      expect(task, isNotNull);
      expect(task, equals(testTask1));
    });

    test('getTaskById returns null when id is missing', () async {
      final task = await repository.getTaskById('non-existent-id');

      expect(task, isNull);
    });

    test('addTask inserts task at beginning of list', () async {
      final newTask = Task(
        id: 'task-3',
        title: 'New Added Task',
      );

      await repository.addTask(newTask);
      final tasks = await repository.getTasks();

      expect(tasks.length, 3);
      expect(tasks.first, equals(newTask));
    });

    test('updateTask correctly replaces existing task', () async {
      final updated = testTask1.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      await repository.updateTask(updated);
      final task = await repository.getTaskById('task-1');

      expect(task, isNotNull);
      expect(task!.title, 'Updated Title');
      expect(task.isCompleted, isTrue);
    });

    test('deleteTask removes task with matching id', () async {
      await repository.deleteTask('task-1');
      final tasks = await repository.getTasks();

      expect(tasks.length, 1);
      expect(tasks.any((t) => t.id == 'task-1'), isFalse);
    });
  });
}

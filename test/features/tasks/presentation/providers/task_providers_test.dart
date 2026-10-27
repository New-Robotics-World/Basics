import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskflow/features/tasks/presentation/screens/task_list_screen.dart';

void main() {
  group('Riverpod Task Providers Tests', () {
    late ProviderContainer container;
    late InMemoryTaskRepository mockRepository;

    const initialTask = Task(
      id: 'task-100',
      title: 'Initial Riverpod Task',
      priority: TaskPriority.high,
      isCompleted: false,
    );

    setUp(() {
      mockRepository = InMemoryTaskRepository(initialTasks: [initialTask]);

      // In Riverpod, ProviderContainer lets us test state in pure Dart!
      // Notice how easily we override taskRepositoryProvider:
      container = ProviderContainer(
        overrides: [taskRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('taskListProvider loads initial tasks from repository', () async {
      // Read initial state
      final tasks = await container.read(taskListProvider.future);

      expect(tasks.length, 1);
      expect(tasks.first.title, 'Initial Riverpod Task');
    });

    test('addTask updates state via taskListProvider', () async {
      const newTask = Task(
        id: 'task-101',
        title: 'New Added Task',
        priority: TaskPriority.low,
      );

      await container.read(taskListProvider.notifier).addTask(newTask);
      final tasks = await container.read(taskListProvider.future);

      expect(tasks.length, 2);
      expect(tasks.first.title, 'New Added Task');
    });

    test('toggleTask toggles completion status', () async {
      await container
          .read(taskListProvider.notifier)
          .toggleTask('task-100', true);
      final tasks = await container.read(taskListProvider.future);

      expect(tasks.first.isCompleted, isTrue);
    });

    test('deleteTask removes task from state', () async {
      await container.read(taskListProvider.notifier).deleteTask('task-100');
      final tasks = await container.read(taskListProvider.future);

      expect(tasks.isEmpty, isTrue);
    });

    test('filteredTasksProvider filters by active status', () async {
      // Add completed task
      const completedTask = Task(
        id: 'task-102',
        title: 'Completed Task',
        isCompleted: true,
      );
      await container.read(taskListProvider.notifier).addTask(completedTask);

      // Set filter to active
      container.read(taskFilterProvider.notifier).setFilter(TaskFilter.active);

      final filtered = container.read(filteredTasksProvider).value ?? [];
      expect(filtered.length, 1);
      expect(filtered.first.id, 'task-100');
    });
  });
}

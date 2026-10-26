import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:taskflow/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/domain/task_repository.dart';
import 'package:taskflow/features/tasks/presentation/screens/task_list_screen.dart';

/// Provides the [TaskRepository] contract.
///
/// In production Clean Architecture, the root ProviderScope initializes the
/// persistent repository (e.g. [SharedPreferencesTaskRepository]) and overrides this provider.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError(
    'taskRepositoryProvider must be overridden in ProviderScope!',
  );
});

/// Notifier for the currently selected [TaskFilter] ('all', 'active', or 'completed').
class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;

  void setFilter(TaskFilter filter) => state = filter;
}

/// Provides the current [TaskFilter].
final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskFilter>(
  TaskFilterNotifier.new,
);

/// Notifier for the active search query text.
class TaskSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

/// Provides the active search query string.
final taskSearchQueryProvider =
    NotifierProvider<TaskSearchQueryNotifier, String>(
      TaskSearchQueryNotifier.new,
    );

/// Async notifier managing the list of [Task] entities and mutations.
///
/// Automatically provides `AsyncValue<List<Task>>` state (Loading, Data, Error).
class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getTasks();
  }

  Future<void> addTask(Task task) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      await repository.addTask(task);
      return repository.getTasks();
    });
  }

  Future<void> toggleTask(String id, bool isCompleted) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      final task = await repository.getTaskById(id);
      if (task != null) {
        final updated = task.copyWith(isCompleted: isCompleted);
        await repository.updateTask(updated);
      }
      return repository.getTasks();
    });
  }

  Future<void> deleteTask(String id) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      await repository.deleteTask(id);
      return repository.getTasks();
    });
  }
}

/// The main provider for tasks, exposing [TaskListNotifier].
final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);

/// Computed / derived provider that filters and searches tasks.
///
/// Whenever tasks, filter, or search query change, this provider
/// automatically recalculates the visible tasks.
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider).toLowerCase();

  return tasksAsync.whenData((tasks) {
    return tasks.where((task) {
      // 1. Status Filter
      final matchesFilter = switch (filter) {
        TaskFilter.all => true,
        TaskFilter.active => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };

      // 2. Search Query Filter
      final matchesQuery =
          searchQuery.isEmpty ||
          task.title.toLowerCase().contains(searchQuery) ||
          task.description.toLowerCase().contains(searchQuery);

      return matchesFilter && matchesQuery;
    }).toList();
  });
});

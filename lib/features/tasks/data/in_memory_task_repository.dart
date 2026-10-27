import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/domain/task_repository.dart';

/// In-memory implementation of [TaskRepository].
///
/// Holds tasks in a local Dart list. Useful for:
/// - Early development before backend/database setup
/// - Fast unit & widget testing
class InMemoryTaskRepository implements TaskRepository {
  /// Creates the repository with optional [initialTasks].
  InMemoryTaskRepository({List<Task>? initialTasks})
    : _tasks = List.of(initialTasks ?? _defaultTasks);

  final List<Task> _tasks;

  static final List<Task> _defaultTasks = [
    Task(
      id: '1',
      title: 'Explore Flutter Project Architecture',
      description:
          'Understand Layer-first vs Feature-first and build clean domain models.',
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    const Task(
      id: '2',
      title: 'Practice Immutable State in Dart',
      description:
          'Master copyWith, == operator, and unmodifiable collections.',
      priority: TaskPriority.medium,
      isCompleted: true,
    ),
  ];

  @override
  Future<List<Task>> getTasks() async {
    // Return an unmodifiable copy to prevent outside code from mutating our internal list directly
    return List.unmodifiable(_tasks);
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}

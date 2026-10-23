import 'package:taskflow/features/tasks/domain/task.dart';

/// Abstract contract for task persistence and data operations.
///
/// In Domain-Driven Design (DDD) & Clean Architecture:
/// - The domain layer defines the *interface* (what operations exist).
/// - The data layer provides the *implementation* (in-memory, SQLite, REST API, etc.).
///
/// Using `abstract interface class` guarantees that any implementation must
/// adhere strictly to this contract without leaking implementation details to UI.
abstract interface class TaskRepository {
  /// Fetches all tasks.
  Future<List<Task>> getTasks();

  /// Fetches a single task by its unique [id], or returns `null` if not found.
  Future<Task?> getTaskById(String id);

  /// Adds a new [task].
  Future<void> addTask(Task task);

  /// Updates an existing [task].
  Future<void> updateTask(Task task);

  /// Deletes a task by its unique [id].
  Future<void> deleteTask(String id);
}

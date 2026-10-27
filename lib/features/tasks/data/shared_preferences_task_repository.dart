import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/domain/task_repository.dart';

/// Persistent implementation of [TaskRepository] using [SharedPreferences].
///
/// Stores tasks as a serialized list of JSON strings across app restarts and reboots.
class SharedPreferencesTaskRepository implements TaskRepository {
  SharedPreferencesTaskRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _storageKey = 'taskflow_tasks_v1';

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

  List<Task> _readTasksFromDisk() {
    final rawList = _prefs.getStringList(_storageKey);
    if (rawList == null) {
      // First app launch: seed with default tasks and persist immediately
      _saveTasksToDisk(_defaultTasks);
      return List.unmodifiable(_defaultTasks);
    }

    try {
      final tasks = rawList
          .map(
            (item) => Task.fromJson(jsonDecode(item) as Map<String, dynamic>),
          )
          .toList();
      return List.unmodifiable(tasks);
    } catch (_) {
      // In case of corrupt data, safely fall back to empty or defaults
      return List.unmodifiable(_defaultTasks);
    }
  }

  Future<void> _saveTasksToDisk(List<Task> tasks) async {
    final rawList = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await _prefs.setStringList(_storageKey, rawList);
  }

  @override
  Future<List<Task>> getTasks() async {
    return _readTasksFromDisk();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final tasks = _readTasksFromDisk();
    try {
      return tasks.firstWhere((t) => t.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> addTask(Task task) async {
    final currentTasks = List<Task>.from(_readTasksFromDisk());
    currentTasks.insert(0, task);
    await _saveTasksToDisk(currentTasks);
  }

  @override
  Future<void> updateTask(Task task) async {
    final currentTasks = List<Task>.from(_readTasksFromDisk());
    final index = currentTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      currentTasks[index] = task;
      await _saveTasksToDisk(currentTasks);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final currentTasks = List<Task>.from(_readTasksFromDisk());
    currentTasks.removeWhere((t) => t.id == id);
    await _saveTasksToDisk(currentTasks);
  }
}

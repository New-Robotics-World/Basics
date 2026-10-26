import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/features/tasks/data/shared_preferences_task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesTaskRepository Tests', () {
    late SharedPreferences prefs;
    late SharedPreferencesTaskRepository repository;

    final testTask1 = Task(
      id: 'pref-1',
      title: 'Persisted Task 1',
      description: 'Saved on disk',
      priority: TaskPriority.high,
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'taskflow_tasks_v1': [
          jsonEncode(testTask1.toJson()),
        ],
      });
      prefs = await SharedPreferences.getInstance();
      repository = SharedPreferencesTaskRepository(prefs);
    });

    test('getTasks reads saved tasks from SharedPreferences', () async {
      final tasks = await repository.getTasks();

      expect(tasks.length, 1);
      expect(tasks.first.id, 'pref-1');
      expect(tasks.first.title, 'Persisted Task 1');
      expect(tasks.first.priority, TaskPriority.high);
    });

    test('addTask persists new task to SharedPreferences', () async {
      final newTask = Task(
        id: 'pref-2',
        title: 'New Persisted Task',
        priority: TaskPriority.low,
      );

      await repository.addTask(newTask);

      final tasks = await repository.getTasks();
      expect(tasks.length, 2);
      expect(tasks.first.id, 'pref-2');

      // Verify directly on raw disk storage
      final rawList = prefs.getStringList('taskflow_tasks_v1');
      expect(rawList?.length, 2);
    });

    test('updateTask updates task and persists change', () async {
      final updated = testTask1.copyWith(
        title: 'Updated Persisted Title',
        isCompleted: true,
      );

      await repository.updateTask(updated);

      final task = await repository.getTaskById('pref-1');
      expect(task?.title, 'Updated Persisted Title');
      expect(task?.isCompleted, isTrue);
    });

    test('deleteTask removes task and updates disk', () async {
      await repository.deleteTask('pref-1');

      final tasks = await repository.getTasks();
      expect(tasks.isEmpty, isTrue);

      final rawList = prefs.getStringList('taskflow_tasks_v1');
      expect(rawList?.isEmpty, isTrue);
    });
  });
}

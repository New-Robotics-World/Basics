import 'package:flutter/material.dart';
import 'package:taskflow/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/domain/task_repository.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_form_dialog.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_item_tile.dart';

/// Filter options for viewing tasks.
enum TaskFilter { all, active, completed }

/// Main Screen for viewing and managing tasks.
///
/// Phase 3 Architecture:
/// - Repository Pattern: Interacts with an abstract [TaskRepository].
/// - Dependency Injection: Accepts a repository via constructor for easy testing.
/// - Presentation layer does not know how or where tasks are persisted.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, this.repository});

  /// The repository instance supplying tasks.
  final TaskRepository? repository;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = true;

  TaskFilter _activeFilter = TaskFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? InMemoryTaskRepository();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _repository.getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  List<Task> get _filteredTasks {
    return _tasks.where((task) {
      // 1. Status Filter
      final matchesFilter = switch (_activeFilter) {
        TaskFilter.all => true,
        TaskFilter.active => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };

      // 2. Search Query Filter
      final matchesQuery =
          _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesQuery;
    }).toList();
  }

  Future<void> _toggleTask(String id, bool isCompleted) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final updatedTask = _tasks[index].copyWith(isCompleted: isCompleted);
    await _repository.updateTask(updatedTask);
    await _loadTasks();
  }

  Future<void> _deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final removedTask = _tasks[index];
    await _repository.deleteTask(id);
    await _loadTasks();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removedTask.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await _repository.addTask(removedTask);
            await _loadTasks();
          },
        ),
      ),
    );
  }

  Future<void> _openAddTaskDialog() async {
    final newTask = await showDialog<Task>(
      context: context,
      builder: (_) => const TaskFormDialog(),
    );

    if (newTask != null) {
      await _repository.addTask(newTask);
      await _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedTasks = _filteredTasks;

    final totalCount = _tasks.length;
    final completedCount = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Filter Segmented Buttons & Stats
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<TaskFilter>(
                        segments: const [
                          ButtonSegment(
                            value: TaskFilter.all,
                            label: Text('All'),
                          ),
                          ButtonSegment(
                            value: TaskFilter.active,
                            label: Text('Active'),
                          ),
                          ButtonSegment(
                            value: TaskFilter.completed,
                            label: Text('Done'),
                          ),
                        ],
                        selected: {_activeFilter},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _activeFilter = newSelection.first;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completedCount/$totalCount',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayedTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.task_alt_outlined,
                    size: 64,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _tasks.isEmpty
                        ? 'No tasks yet!'
                        : 'No tasks match your search/filter.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tasks.isEmpty
                        ? 'Tap the button below to add your first task.'
                        : 'Try selecting a different filter tab.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: displayedTasks.length,
              itemBuilder: (context, index) {
                final task = displayedTasks[index];
                return TaskItemTile(
                  task: task,
                  onToggle: (completed) => _toggleTask(task.id, completed),
                  onDelete: () => _deleteTask(task.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}

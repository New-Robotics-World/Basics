import 'package:flutter/material.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_form_dialog.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_item_tile.dart';

/// Filter options for viewing tasks.
enum TaskFilter { all, active, completed }

/// Main Screen for viewing and managing tasks.
///
/// Phase 2 Architecture:
/// - State Ownership: Managed directly via `setState` in this coordinator widget.
/// - Data: Stored locally in a private list `_tasks`.
/// - Children: Child widgets receive immutable data and invoke callbacks to trigger mutations.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // In Phase 2, state lives directly in the StatefulWidget.
  // In Phase 3 & 4, we will extract this into Repositories and ViewModels/StateNotifiers!
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Explore Flutter Project Architecture',
      description:
          'Understand Layer-first vs Feature-first and build clean domain models.',
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'Practice Immutable State in Dart',
      description:
          'Master copyWith, == operator, and unmodifiable collections.',
      priority: TaskPriority.medium,
      isCompleted: true,
    ),
  ];

  TaskFilter _activeFilter = TaskFilter.all;
  String _searchQuery = '';

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

  void _toggleTask(String id, bool isCompleted) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
      }
    });
  }

  void _deleteTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final removedTask = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removedTask.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _tasks.insert(index, removedTask);
            });
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
      setState(() {
        _tasks.insert(0, newTask);
      });
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
      body: displayedTasks.isEmpty
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

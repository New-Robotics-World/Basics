import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/providers/task_providers.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_form_dialog.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_item_tile.dart';

/// Filter options for viewing tasks.
enum TaskFilter { all, active, completed }

/// Main Screen for viewing and managing tasks.
///
/// Phase 5 Architecture:
/// - Primary Architecture: Feature-First + Riverpod + Repository Pattern.
/// - The UI is a pure [ConsumerWidget]; it owns ZERO business logic or storage state.
/// - It reactively observes Riverpod providers using [WidgetRef].
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  Future<void> _openAddTaskDialog(BuildContext context, WidgetRef ref) async {
    final newTask = await showDialog<Task>(
      context: context,
      builder: (_) => const TaskFormDialog(),
    );

    if (newTask != null) {
      await ref.read(taskListProvider.notifier).addTask(newTask);
    }
  }

  void _deleteTask(BuildContext context, WidgetRef ref, Task task) {
    unawaited(ref.read(taskListProvider.notifier).deleteTask(task.id));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${task.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            unawaited(ref.read(taskListProvider.notifier).addTask(task));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // 1. Reactive state consumption via Riverpod
    final filteredTasksAsync = ref.watch(filteredTasksProvider);
    final allTasksAsync = ref.watch(taskListProvider);
    final activeFilter = ref.watch(taskFilterProvider);

    // Calculate completed vs total metrics safely from raw task state
    final allTasks = allTasksAsync.value ?? [];
    final totalCount = allTasks.length;
    final completedCount = allTasks.where((t) => t.isCompleted).length;

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
                  onChanged: (val) {
                    ref.read(taskSearchQueryProvider.notifier).setQuery(val);
                  },
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
                        selected: {activeFilter},
                        onSelectionChanged: (newSelection) {
                          ref
                              .read(taskFilterProvider.notifier)
                              .setFilter(newSelection.first);
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
      body: filteredTasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text('Failed to load tasks: $error'),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(taskListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (displayedTasks) {
          if (displayedTasks.isEmpty) {
            return Center(
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
                    allTasks.isEmpty
                        ? 'No tasks yet!'
                        : 'No tasks match your search/filter.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    allTasks.isEmpty
                        ? 'Tap the button below to add your first task.'
                        : 'Try selecting a different filter tab.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(taskListProvider);
              await ref.read(taskListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: displayedTasks.length,
              itemBuilder: (context, index) {
                final task = displayedTasks[index];
                return TaskItemTile(
                  task: task,
                  onToggle: (completed) {
                    ref
                        .read(taskListProvider.notifier)
                        .toggleTask(task.id, completed);
                  },
                  onDelete: () => _deleteTask(context, ref, task),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTaskDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}

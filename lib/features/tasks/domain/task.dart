import 'package:flutter/material.dart';

/// Represents the urgency/importance level of a [Task].
enum TaskPriority {
  low('Low', Colors.teal),
  medium('Medium', Colors.amber),
  high('High', Colors.deepOrange);

  const TaskPriority(this.label, this.color);

  final String label;
  final Color color;
}

/// Core domain entity representing a Task in TaskFlow.
///
/// Notice this class is immutable (`@immutable` behavior via `final` fields).
/// In modern Flutter architecture, immutability guarantees:
/// 1. Predictable state updates (no accidental side-effects in other parts of the widget tree).
/// 2. Clean equality comparisons (essential for Riverpod, Bloc, and widget diffing).
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;

  /// Creates a copy of this Task with the given fields replaced by the new values.
  ///
  /// This is the idiomatic pattern for "updating" immutable objects in Dart.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Converts this [Task] to a JSON-compatible map for local/remote persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
    };
  }

  /// Recreates a [Task] instance from a JSON map.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          dueDate == other.dueDate &&
          priority == other.priority &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      Object.hash(id, title, description, dueDate, priority, isCompleted);

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: ${priority.name}, isCompleted: $isCompleted)';
  }
}

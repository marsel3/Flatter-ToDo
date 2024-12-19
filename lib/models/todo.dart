import 'package:uuid/uuid.dart';

enum Priority {
  low,
  medium,
  high,
}

class Todo {
  final String id;
  String title;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  Priority priority;

  Todo({
    String? id,
    required this.title,
    this.isCompleted = false,
    Priority? priority,
    this.dueDate,
    DateTime? createdAt,
  }) :
        id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        priority = priority ?? Priority.medium;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.index,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      priority: Priority.values[json['priority'] as int],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }
}
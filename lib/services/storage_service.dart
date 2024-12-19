import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  static const String _key = 'todos';

  Future<void> saveTodos(List<Todo> todos) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedTodos = json.encode(
      todos.map((todo) => {
        'id': todo.id,
        'title': todo.title,
        'isCompleted': todo.isCompleted,
        'createdAt': todo.createdAt.toIso8601String(),
        'dueDate': todo.dueDate?.toIso8601String(),
        'priority': todo.priority.index,
      }).toList(),
    );
    await prefs.setString(_key, encodedTodos);
  }

  Future<List<Todo>> loadTodos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedTodos = prefs.getString(_key);

    if (encodedTodos == null) return [];

    final List<dynamic> decodedTodos = json.decode(encodedTodos);
    return decodedTodos.map((todo) {
      final Map<String, dynamic> todoMap = Map<String, dynamic>.from(todo);
      return Todo(
        title: todoMap['title'] as String,
        isCompleted: todoMap['isCompleted'] as bool,
        priority: Priority.values[todoMap['priority'] as int],
        dueDate: todoMap['dueDate'] != null
            ? DateTime.parse(todoMap['dueDate'] as String)
            : null,
      );
    }).toList();
  }
}
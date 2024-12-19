import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';

enum TodoFilter {
  all,
  completed,
  active,
}

enum TodoSort {
  createdAt,
  priority,
  dueDate,
  completion,
}

class TodoNotifier extends StateNotifier<List<Todo>> {
  final StorageService _storage = StorageService();

  TodoNotifier() : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    state = await _storage.loadTodos();
  }

  Future<void> addTodo(Todo todo) async {
    state = [...state, todo];
    await _storage.saveTodos(state);
  }

  Future<void> toggleTodo(String id) async {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            title: todo.title,
            isCompleted: !todo.isCompleted,
            priority: todo.priority,
            dueDate: todo.dueDate,
            createdAt: todo.createdAt, // Сохраняем оригинальное время создания
          )
        else
          todo,
    ];
    await _storage.saveTodos(state);
  }

  Future<void> updateTodo(String id, {
    String? title,
    Priority? priority,
    DateTime? dueDate,
  }) async {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            title: title ?? todo.title,
            isCompleted: todo.isCompleted,
            priority: priority ?? todo.priority,
            dueDate: dueDate ?? todo.dueDate,
            createdAt: todo.createdAt, // Сохраняем оригинальное время создания
          )
        else
          todo,
    ];
    await _storage.saveTodos(state);
  }

  Future<void> deleteTodo(String id) async {
    state = state.where((todo) => todo.id != id).toList();
    await _storage.saveTodos(state);
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);
final todoSortProvider = StateProvider<TodoSort>((ref) => TodoSort.createdAt);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

final filteredAndSortedTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoProvider);
  final filter = ref.watch(todoFilterProvider);
  final sort = ref.watch(todoSortProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  var filteredTodos = [...todos];

  switch (filter) {
    case TodoFilter.all:
      break;
    case TodoFilter.completed:
      filteredTodos = filteredTodos.where((todo) => todo.isCompleted).toList();
      break;
    case TodoFilter.active:
      filteredTodos = filteredTodos.where((todo) => !todo.isCompleted).toList();
      break;
  }

  if (searchQuery.isNotEmpty) {
    filteredTodos = filteredTodos
        .where((todo) => todo.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  switch (sort) {
    case TodoSort.createdAt:
      filteredTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case TodoSort.priority:
      filteredTodos.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      break;
    case TodoSort.dueDate:
      filteredTodos.sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      break;
    case TodoSort.completion:
      filteredTodos.sort((a, b) {
        if (a.isCompleted == b.isCompleted) {
          return a.createdAt.compareTo(b.createdAt); // Изменён порядок сортировки
        }
        return a.isCompleted ? 1 : -1;
      });
      break;
  }

  return filteredTodos;
});
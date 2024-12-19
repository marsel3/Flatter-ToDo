import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import 'dialogs/add_todo_dialog.dart';
import 'dialogs/edit_todo_dialog.dart';
import '../models/todo.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredAndSortedTodosProvider);
    final groupedTodos = _groupTodosByDate(todos);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'ToDo App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () => _showSortDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск задач...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Все даты'),
                        selected: selectedDate == null,
                        onSelected: (selected) {
                          ref.read(selectedDateProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: 8),
                      ...groupedTodos.keys.map((date) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(_formatDateHeader(date)),
                            selected: selectedDate?.dateOnly == date,
                            onSelected: (selected) {
                              ref.read(selectedDateProvider.notifier).state = selected ? date : null;
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildTodosList(
              selectedDate == null ? groupedTodos : {
                if (groupedTodos.containsKey(selectedDate.dateOnly))
                  selectedDate.dateOnly: groupedTodos[selectedDate.dateOnly]!
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        label: const Text('Добавить задачу'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodosList(Map<DateTime, List<Todo>> groupedTodos) {
    if (groupedTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Нет задач',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTodos.length,
      itemBuilder: (context, index) {
        final date = groupedTodos.keys.elementAt(index);
        final todosForDate = groupedTodos[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _formatDateHeader(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: todosForDate.map((todo) {
                  return TodoTile(todo: todo);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Map<DateTime, List<Todo>> _groupTodosByDate(List<Todo> todos) {
    final grouped = <DateTime, List<Todo>>{};

    for (var todo in todos) {
      final date = todo.dueDate?.dateOnly ?? DateTime.now().dateOnly;
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(todo);
    }

    return Map.fromEntries(
        grouped.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Сегодня';
    } else if (dateOnly == tomorrow) {
      return 'Завтра';
    } else {
      return DateFormat('d MMMM y', 'ru').format(date);
    }
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сортировка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TodoSort.values.map((sort) {
            return RadioListTile<TodoSort>(
              title: Text(_getSortTitle(sort)),
              value: sort,
              groupValue: ref.watch(todoSortProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(todoSortProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getSortTitle(TodoSort sort) {
    switch (sort) {
      case TodoSort.createdAt:
        return 'По дате создания';
      case TodoSort.priority:
        return 'По приоритету';
      case TodoSort.dueDate:
        return 'По дате окончания';
      case TodoSort.completion:
        return 'По статусу выполнения';
    }
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Фильтр'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TodoFilter.values.map((filter) {
            return RadioListTile<TodoFilter>(
              title: Text(_getFilterTitle(filter)),
              value: filter,
              groupValue: ref.watch(todoFilterProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(todoFilterProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterTitle(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'Все задачи';
      case TodoFilter.completed:
        return 'Выполненные';
      case TodoFilter.active:
        return 'Активные';
    }
  }
}

class TodoTile extends ConsumerWidget {
  final Todo todo;

  const TodoTile({
    Key? key,
    required this.todo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(todo.id),
      onDismissed: (_) {
        ref.read(todoProvider.notifier).deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Задача удалена'),
            action: SnackBarAction(
              label: 'Отменить',
              onPressed: () {
                ref.read(todoProvider.notifier).addTodo(todo);
              },
            ),
          ),
        );
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.isCompleted,
          activeColor: Colors.green,
          shape: const CircleBorder(),
          onChanged: (_) {
            ref.read(todoProvider.notifier).toggleTodo(todo.id);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: todo.dueDate != null
            ? Text(
          DateFormat('d MMMM y', 'ru').format(todo.dueDate!),
          style: TextStyle(
            color: Colors.grey[600],
          ),
        )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getPriorityIcon(todo.priority),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return const Icon(Icons.priority_high, color: Colors.red);
      case Priority.medium:
        return const Icon(Icons.remove, color: Colors.orange);
      case Priority.low:
        return const Icon(Icons.arrow_downward, color: Colors.green);
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => EditTodoDialog(todo: todo),
    );
  }
}

extension DateOnlyCompare on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
}
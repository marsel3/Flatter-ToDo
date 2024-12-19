import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';

class AddTodoDialog extends ConsumerStatefulWidget {
  const AddTodoDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<AddTodoDialog> {
  final _titleController = TextEditingController();
  DateTime? _dueDate;
  Priority _priority = Priority.medium;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить задачу'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название задачи',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Приоритет',
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_getPriorityText(priority)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Дата окончания: '),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _dueDate = date;
                      });
                    }
                  },
                  child: Text(
                    _dueDate != null
                        ? '${_dueDate!.day}.${_dueDate!.month}.${_dueDate!.year}'
                        : 'Выбрать',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              final todo = Todo(
                title: _titleController.text,
                priority: _priority,
                dueDate: _dueDate,
              );
              ref.read(todoProvider.notifier).addTodo(todo);
              Navigator.pop(context);
            }
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'Высокий';
      case Priority.medium:
        return 'Средний';
      case Priority.low:
        return 'Низкий';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
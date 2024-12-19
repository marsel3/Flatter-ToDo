// lib/screens/dialogs/edit_todo_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';

class EditTodoDialog extends ConsumerStatefulWidget {
  final Todo todo;

  const EditTodoDialog({
    Key? key,
    required this.todo,
  }) : super(key: key);

  @override
  ConsumerState<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends ConsumerState<EditTodoDialog> {
  late TextEditingController _titleController;
  late DateTime? _dueDate;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _dueDate = widget.todo.dueDate;
    _priority = widget.todo.priority;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать задачу'),
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
                      initialDate: _dueDate ?? DateTime.now(),
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
              ref.read(todoProvider.notifier).updateTodo(
                widget.todo.id,
                title: _titleController.text,
                priority: _priority,
                dueDate: _dueDate,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Сохранить'),
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
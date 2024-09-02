import 'package:flutter/material.dart';

import '../../domain/entities/todo.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final Function(String) onDelete;
  final Function(Todo) onUpdate;

  const TodoListItem(
      {super.key,
      required this.todo,
      required this.onDelete,
      required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title),
      subtitle: Text(todo.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditDialog(context, todo);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDelete(todo.id);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Todo todo) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedTodo = Todo(
                  id: todo.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  isCompleted: todo.isCompleted,
                );

                onUpdate(updatedTodo);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/todo.dart';
import '../blocs/todo_bloc.dart';
import '../blocs/todo_event.dart';
import 'todo_list_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  const TodoList({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(child: Text('No todos available.'));
    }
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoListItem(
          todo: todo,
          onDelete: (id) {
            context.read<TodoBloc>().add(DeleteTodoEvent(id));
          },
          onUpdate: (updatedTodo) {
            context.read<TodoBloc>().add(UpdateTodoEvent(updatedTodo));
          },
        );
      },
    );
  }
}

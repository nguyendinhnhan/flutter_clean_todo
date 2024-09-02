import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/todo_bloc.dart';
import '../blocs/todo_event.dart';
import '../blocs/todo_state.dart';
import '../../domain/entities/todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoaded) {
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final todo = state.todos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<TodoBloc>().add(DeleteTodoEvent(todo.id));
                    },
                  ),
                );
              },
            );
          } else if (state is TodoError) {
            return Center(
                child: Text('Failed to load todos: ${state.message}'));
          } else {
            return const Center(child: Text('No todos available.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Creating a default Todo item
          final defaultTodo = Todo(
            id: DateTime.now().toString(),
            title: 'Default Todo',
            description: 'This is a default todo description',
          );

          // Adding the default Todo item to the list
          context.read<TodoBloc>().add(AddTodoEvent(defaultTodo));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;

  TodoBloc(this.repository) : super(TodoLoading()) {
    on<LoadTodos>((event, emit) async {
      emit(TodoLoading());
      try {
        final todos = await repository.getTodos();
        emit(TodoLoaded(todos));
      } catch (error) {
        emit(TodoError("Failed to load todos"));
      }
    });

    on<AddTodoEvent>((event, emit) async {
      await repository.addTodo(event.todo);
      add(LoadTodos());
    });

    on<DeleteTodoEvent>((event, emit) async {
      await repository.deleteTodo(event.id);
      add(LoadTodos());
    });
  }
}

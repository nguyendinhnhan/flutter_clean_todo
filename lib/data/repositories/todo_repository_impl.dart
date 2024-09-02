import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../data_sources/todo_local_data_source.dart';
import '../data_sources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  final TodoRemoteDataSource remoteDataSource;

  TodoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final remoteTodos = await remoteDataSource.getTodosFromRemote();
      // Optionally, you could save these to local for offline access.
      return remoteTodos;
    } catch (e) {
      // Fallback to local data if remote fetch fails.
      final todoModels = await localDataSource.getTodosFromLocal();
      return todoModels.map((model) => model).toList();
    }
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final todoModel = TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
    );
    await remoteDataSource.addTodoToRemote(todoModel);
    await localDataSource
        .saveTodoToLocal(todoModel); // Optional: Save to local as well.
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final todoModel = TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
    );
    await remoteDataSource.updateTodoInRemote(todoModel);
    await localDataSource
        .updateTodoInLocal(todoModel); // Optional: Save to local as well.
  }

  @override
  Future<void> deleteTodo(String id) async {
    await remoteDataSource.deleteTodoFromRemote(id);
    await localDataSource
        .deleteTodoFromLocal(id); // Optional: Save to local as well.
  }
}

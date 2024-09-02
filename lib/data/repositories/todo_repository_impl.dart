import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../data_sources/todo_local_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Todo>> getTodos() async {
    final todoModels = await localDataSource.getTodosFromLocal();
    return todoModels.map((model) => model).toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final todoModel = TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
    );
    return await localDataSource.saveTodoToLocal(todoModel);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final todoModel = TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
    );
    return await localDataSource.updateTodoInLocal(todoModel);
  }

  @override
  Future<void> deleteTodo(String id) async {
    return await localDataSource.deleteTodoFromLocal(id);
  }
}

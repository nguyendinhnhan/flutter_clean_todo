import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../data_sources/todo_local_data_source.dart';
import '../data_sources/todo_remote_data_source.dart';
import '../models/todo_model.dart';
import 'sync_queue.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  final TodoRemoteDataSource remoteDataSource;
  final SyncQueue syncQueue = SyncQueue();

  TodoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Todo>> getTodos() async {
    try {
      // Fetch remote todos
      final remoteTodos = await remoteDataSource.getTodosFromRemote();
      for (var todo in remoteTodos) {
        print('getTodos remoteTodos: $todo');
      }
      // Sync local storage with remote todos
      await _syncLocalWithRemote(remoteTodos);
      return remoteTodos;
    } catch (e) {
      print('getTodos error: $e');
      final localTodos = await localDataSource.getTodosFromLocal();
      for (var todo in localTodos) {
        print('getTodos localTodos: $todo');
      }
      return localTodos;
    }
  }

  Future<void> _syncLocalWithRemote(List<TodoModel> remoteTodos) async {
    // Get current local todos
    final localTodos = await localDataSource.getTodosFromLocal();
    // Create a set of local todo IDs for quick lookup
    final localTodoIds = localTodos.map((todo) => todo.id).toSet();

    // Only add remote todos that don't already exist in local storage
    for (var remoteTodo in remoteTodos) {
      print('_syncLocalWithRemote $remoteTodo');
      if (!localTodoIds.contains(remoteTodo.id)) {
        await localDataSource.saveTodoToLocal(remoteTodo);
      }
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
    await localDataSource.saveTodoToLocal(todoModel);
    // Queue syncing with remote
    _trySync(() => remoteDataSource.addTodoToRemote(todoModel));
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final todoModel = TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
    );
    await localDataSource.updateTodoInLocal(todoModel);
    // Queue syncing with remote
    _trySync(() => remoteDataSource.updateTodoInRemote(todoModel));
  }

  @override
  Future<void> deleteTodo(String id) async {
    await localDataSource.deleteTodoFromLocal(id);
    // Queue syncing with remote
    _trySync(() => remoteDataSource.deleteTodoFromRemote(id));
  }

  void _trySync(Future<void> Function() syncFunction) async {
    try {
      await syncFunction();
    } catch (e) {
      print("_trySync error: $e");
      // Add to sync queue if sync fails
      syncQueue.addToQueue(syncFunction);
    }
  }

  // Call this method on network connectivity changes
  void onNetworkAvailable() {
    syncQueue.processQueue();
  }
}

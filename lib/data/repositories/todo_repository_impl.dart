import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../data_sources/todo_local_data_source.dart';
import '../data_sources/todo_remote_data_source.dart';
import '../models/todo_model.dart';
import '../data_sources/sync_queue_data_source.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  final TodoRemoteDataSource remoteDataSource;
  final SyncQueueDataSource syncQueueDataSource;

  TodoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.syncQueueDataSource,
  });

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final remoteTodos = await remoteDataSource.getTodosFromRemote();
      await _syncLocalWithRemote(remoteTodos);
      return remoteTodos;
    } catch (e) {
      print('getTodos error: $e');
      final localTodos = await localDataSource.getTodosFromLocal();
      return localTodos;
    }
  }

  Future<void> _syncLocalWithRemote(List<TodoModel> remoteTodos) async {
    final localTodos = await localDataSource.getTodosFromLocal();
    final localTodoIds = localTodos.map((todo) => todo.id).toSet();

    // Only add remote todos that don't already exist in local storage
    for (var remoteTodo in remoteTodos) {
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

    final operation = {
      'action': 'add',
      'todo': todoModel.toJson(),
    };

    await _queueOrSync(
        operation, () => remoteDataSource.addTodoToRemote(todoModel));
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

    final operation = {
      'action': 'update',
      'todo': todoModel.toJson(),
    };

    await _queueOrSync(
        operation, () => remoteDataSource.updateTodoInRemote(todoModel));
  }

  @override
  Future<void> deleteTodo(String id) async {
    await localDataSource.deleteTodoFromLocal(id);

    final operation = {
      'action': 'delete',
      'id': id,
    };

    await _queueOrSync(
        operation, () => remoteDataSource.deleteTodoFromRemote(id));
  }

  Future<void> _queueOrSync(Map<String, dynamic> operation,
      Future<void> Function() syncFunction) async {
    try {
      await syncFunction();
    } catch (e) {
      // Offline, queue the operation for later sync
      await syncQueueDataSource.addOperationToQueue(operation);
    }
  }

  Future<void> processSyncQueue() async {
    final queue = await syncQueueDataSource.getSyncQueue();
    for (var operation in queue) {
      try {
        final action = operation['action'];
        if (action == 'add') {
          final todo = TodoModel.fromJson(operation['todo']);
          await remoteDataSource.addTodoToRemote(todo);
        } else if (action == 'update') {
          final todo = TodoModel.fromJson(operation['todo']);
          await remoteDataSource.updateTodoInRemote(todo);
        } else if (action == 'delete') {
          final id = operation['id'];
          await remoteDataSource.deleteTodoFromRemote(id);
        }
      } catch (e) {
        // Stop processing if a sync fails
        break;
      }
    }
    // Clear the queue if everything synced successfully
    await syncQueueDataSource.clearQueue();
  }

  void onNetworkAvailable() {
    processSyncQueue();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodosFromLocal();
  Future<void> saveTodoToLocal(TodoModel todo);
  Future<void> updateTodoInLocal(TodoModel todo);
  Future<void> deleteTodoFromLocal(String id);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final SharedPreferences sharedPreferences;
  final String todosKey = 'todos';

  TodoLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<TodoModel>> getTodosFromLocal() async {
    final todosString = sharedPreferences.getString(todosKey);
    print('todosString $todosString');
    if (todosString != null && todosString.isNotEmpty) {
      final List<dynamic> decodedJson = json.decode(todosString);
      return decodedJson
          .map((jsonItem) => TodoModel.fromJson(jsonItem))
          .toList();
    }
    return [];
  }

  @override
  Future<void> saveTodoToLocal(TodoModel todo) async {
    print('saveTodoToLocal $todo');
    final todos = await getTodosFromLocal();
    todos.add(todo);
    final String todosString =
        json.encode(todos.map((todo) => todo.toJson()).toList());
    await sharedPreferences.setString(todosKey, todosString);
  }

  @override
  Future<void> updateTodoInLocal(TodoModel updatedTodo) async {
    final todos = await getTodosFromLocal();
    final index = todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      todos[index] = updatedTodo;
      final String todosString =
          json.encode(todos.map((todo) => todo.toJson()).toList());
      await sharedPreferences.setString(todosKey, todosString);
    }
  }

  @override
  Future<void> deleteTodoFromLocal(String id) async {
    final todos = await getTodosFromLocal();
    todos.removeWhere((todo) => todo.id == id);
    final String todosString =
        json.encode(todos.map((todo) => todo.toJson()).toList());
    await sharedPreferences.setString(todosKey, todosString);
  }
}

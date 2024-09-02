import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodosFromRemote();
  Future<void> addTodoToRemote(TodoModel todo);
  Future<void> updateTodoInRemote(TodoModel todo);
  Future<void> deleteTodoFromRemote(String id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'http://localhost:3000/todos';

  TodoRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TodoModel>> getTodosFromRemote() async {
    final response = await client.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> decodedJson = json.decode(response.body);
      return decodedJson
          .map((jsonItem) => TodoModel.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  @override
  Future<void> addTodoToRemote(TodoModel todo) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add todo');
    }
  }

  @override
  Future<void> updateTodoInRemote(TodoModel todo) async {
    final response = await client.put(
      Uri.parse('$baseUrl/${todo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update todo');
    }
  }

  @override
  Future<void> deleteTodoFromRemote(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }
}

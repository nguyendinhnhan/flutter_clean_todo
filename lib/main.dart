import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/data_sources/todo_local_data_source.dart';
import 'data/data_sources/todo_remote_data_source.dart';
import 'data/repositories/todo_repository_impl.dart';
import 'domain/repositories/todo_repository.dart';
import 'presentation/blocs/todo_bloc.dart';
import 'presentation/blocs/todo_event.dart';
import 'presentation/pages/todo_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void clearLocalStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear local storage on app startup
  // clearLocalStorage();

  // Initialize SharedPreferences and HTTP client
  final sharedPreferences = await SharedPreferences.getInstance();
  final client = http.Client();

  // Create the TodoLocalDataSource and TodoRemoteDataSource
  final todoLocalDataSource = TodoLocalDataSourceImpl(sharedPreferences);
  final todoRemoteDataSource = TodoRemoteDataSourceImpl(
    client: client,
  );

  // Create the TodoRepository implementation
  final todoRepository = TodoRepositoryImpl(
      localDataSource: todoLocalDataSource,
      remoteDataSource: todoRemoteDataSource);

  runApp(MyApp(todoRepository: todoRepository));
}

class MyApp extends StatelessWidget {
  final TodoRepository todoRepository;

  const MyApp({super.key, required this.todoRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: todoRepository,
      child: BlocProvider(
        create: (context) => TodoBloc(todoRepository)..add(LoadTodos()),
        child: MaterialApp(
          title: 'Todo App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const TodoPage(),
        ),
      ),
    );
  }
}

# flutter_clean_todo

Refer Link: https://chatgpt.com/share/238c66fa-56b3-4f02-a713-b7feda4c7e75

**Clean Architecture pattern with the BLoC (Business Logic Component) pattern:**

#### 1. Domain Layer (Business Logic)
- **Entities**: Define the core classes that represent your domain objects. In this case, it could be a Todo class.
- **Repositories**: Abstract classes that define the contract for data operations (e.g., TodoRepository).
- **Use Cases**: Classes that represent the actions or operations that can be performed, like AddTodo, GetTodos, DeleteTodo.
#### 2. Data Layer (Data Management)
- **Models**: Define data structures that mirror the API or database format. These can be converted to/from entities (e.g., TodoModel).
- **Data Sources**: Define how you fetch data, such as local (e.g., SQLite) or remote (e.g., REST API) sources (TodoLocalDataSource, TodoRemoteDataSource).
- **Repository Implementations**: Implement the TodoRepository by combining the data sources to fulfill the contract (TodoRepositoryImpl).
#### 3. Presentation Layer (User Interface)
- **BLoC/ Cubit**: Handle state management and logic for UI components. Each feature would have its own BLoC (e.g., TodoBloc or TodoCubit).
- **UI Widgets**: Stateless and Stateful widgets that represent the visual part of the app. These widgets interact with the BLoC to retrieve and display data (TodoPage, TodoList).

**Folder Structure Example**

```
lib/
│
├── domain/
│   ├── entities/
│   │   └── todo.dart
│   ├── repositories/
│   │   └── todo_repository.dart
│   └── use_cases/
│       ├── add_todo.dart
│       ├── delete_todo.dart
│       └── get_todos.dart
│
├── data/
│   ├── models/
│   │   └── todo_model.dart
│   ├── data_sources/
│   │   ├── todo_local_data_source.dart
│   │   └── todo_remote_data_source.dart
│   └── repositories/
│       └── todo_repository_impl.dart
│
├── presentation/
│   ├── blocs/
│   │   └── todo_bloc.dart
│   ├── pages/
│   │   └── todo_page.dart
│   └── widgets/
│       └── todo_list.dart
│
└── main.dart
```
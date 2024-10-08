class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  Todo copyWith({bool? isCompleted}) {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

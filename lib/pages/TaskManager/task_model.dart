class Task {
  String? id;
  String? taskText;
  bool isDone;

  Task({
    required this.id,
    required this.taskText,
    this.isDone = false,
  });

  static List<Task> taskList() {
    return []; // Empty initial task list
  }
}

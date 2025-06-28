class Task {
  String id;
  String taskText;
  bool isDone;
  DateTime? startTime;
  DateTime? endTime;
  String? date;

  Task({
    required this.id,
    required this.taskText,
    this.isDone = false,
    this.startTime,
    this.endTime,
    this.date,
  });

  static List<Task> taskList() {
    return [];
  }
}

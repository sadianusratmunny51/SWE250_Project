class Task {
  String id;
  String taskText;
  bool isDone;
  DateTime? startTime; // Add start time
  DateTime? endTime; // Add end time

  Task({
    required this.id,
    required this.taskText,
    this.isDone = false,
    this.startTime,
    this.endTime,
  });

  static List<Task> taskList() {
    return [];
  }
}

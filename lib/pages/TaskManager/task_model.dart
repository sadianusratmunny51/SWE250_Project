class Task {
  String id;
  String taskText;
  bool isDone;
  DateTime? startTime; // Add start time
  DateTime? endTime; // Add end time
  String? date; // NEW: date string in "YYYY-MM-DD" format

  Task({
    required this.id,
    required this.taskText,
    this.isDone = false,
    this.startTime,
    this.endTime,
    this.date, // add to constructor
  });

  static List<Task> taskList() {
    return [];
  }
}

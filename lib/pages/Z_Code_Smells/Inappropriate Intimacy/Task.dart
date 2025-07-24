import 'package:cloud_firestore/cloud_firestore.dart';

class UserTask {
  String id;
  String _taskText;
  bool isDone;
  DateTime? _startTime;
  DateTime? _endTime;

  UserTask({
    required this.id,
    required String taskText,
    required this.isDone,
    DateTime? startTime,
    DateTime? endTime,
  })  : _taskText = taskText,
        _startTime = startTime,
        _endTime = endTime;

  String get taskText => _taskText;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  Duration get duration => (_startTime != null && _endTime != null)
      ? _endTime!.difference(_startTime!)
      : Duration.zero;

  factory UserTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserTask(
      id: doc.id,
      taskText: data['taskText'] ?? '',
      isDone: data['isDone'] ?? false,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
    );
  }
}

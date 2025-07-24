import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum MenuAction { edit, delete }

class MyMonthPage extends StatefulWidget {
  const MyMonthPage({super.key});

  @override
  State<MyMonthPage> createState() => _MyMonthPageState();
}

class _MyMonthPageState extends State<MyMonthPage> {
  final List<String> months = List.generate(12, (index) {
    return DateFormat.MMMM().format(DateTime(0, index + 1));
  });

  List<int> years = [];
  int selectedMonthIndex = DateTime.now().month - 1;
  int selectedYear = DateTime.now().year;

  Map<String, Map<String, dynamic>> _events = {};

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    years = List.generate(21, (index) => currentYear - 10 + index);
    loadEventsForMonth();
  }

  DateTime getLastDayOfMonth(int year, int month) {
    final beginningNextMonth =
        (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
    return beginningNextMonth.subtract(Duration(seconds: 1));
  }

  Future<void> loadEventsForMonth() async {
    final start = DateTime(selectedYear, selectedMonthIndex + 1, 1);
    final end = getLastDayOfMonth(selectedYear, selectedMonthIndex + 1);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .get();

    setState(() {
      _events.clear();
      for (var doc in snapshot.docs) {
        final date = (doc['date'] as Timestamp).toDate();
        final key = DateFormat('yyyy-MM-dd').format(date);
        _events[key] = {
          'id': doc.id,
          'title': doc['title'],
          'date': date,
        };
      }
    });
  }

  Future<void> _editEvent(
      String docId, String oldTitle, DateTime oldDate) async {
    final titleController = TextEditingController(text: oldTitle);
    DateTime selectedDate = oldDate;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController),
            ElevatedButton(
              child: Text("Pick Date"),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) selectedDate = picked;
              },
            )
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Save"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('events')
                  .doc(docId)
                  .update({
                'title': titleController.text.trim(),
                'date': Timestamp.fromDate(selectedDate),
              });
              await loadEventsForMonth();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Future<void> _deleteEvent(String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(docId)
        .delete();
    await loadEventsForMonth();
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday =
        DateTime(selectedYear, selectedMonthIndex + 1, 1).weekday % 7;
    final totalDays = DateTime(selectedYear, selectedMonthIndex + 2, 0).day;
    final today = DateTime.now();

    List<Widget> weekdayHeaders =
        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            .map((label) => Expanded(
                  child: Center(
                    child: Text(label,
                        style: TextStyle(
                            color: Colors.blue.shade200,
                            fontWeight: FontWeight.bold)),
                  ),
                ))
            .toList();

    List<Widget> dayCells = [];
    for (int i = 0; i < firstWeekday; i++) {
      dayCells.add(const Expanded(child: SizedBox()));
    }

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(selectedYear, selectedMonthIndex + 1, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final hasEvent = _events.containsKey(dateKey);
      final isToday = date.day == today.day &&
          date.month == today.month &&
          date.year == today.year;

      dayCells.add(
        Expanded(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.blue
                      : hasEvent
                          ? Colors.deepPurple
                          : Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    while (dayCells.length % 7 != 0) {
      dayCells.add(const Expanded(child: SizedBox()));
    }

    List<Widget> calendarRows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      calendarRows.add(Row(children: dayCells.sublist(i, i + 7)));
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("My Month",
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  dropdownColor: Colors.grey.shade900,
                  value: selectedMonthIndex,
                  style: const TextStyle(color: Colors.white),
                  items: List.generate(months.length, (index) {
                    //month  select
                    return DropdownMenuItem(
                      value: index,
                      child: Text(months[index]),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedMonthIndex = val;
                      });
                      loadEventsForMonth();
                    }
                  },
                ),
                const SizedBox(width: 24),
                //year select
                DropdownButton<int>(
                  dropdownColor: Colors.grey.shade900,
                  value: selectedYear,
                  style: const TextStyle(color: Colors.white),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedYear = val;
                      });
                      loadEventsForMonth();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(children: weekdayHeaders),
                  const SizedBox(height: 8),
                  ...calendarRows,
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Events",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _events.isEmpty
                  ? const Center(
                      child: Text("No events this month",
                          style: TextStyle(color: Colors.white38)),
                    )
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final entry = _events.entries.elementAt(index);
                        final docId = entry.value['id'];
                        final eventTitle = entry.value['title'];
                        final eventDate = DateFormat('yyyy-MM-dd')
                            .format(entry.value['date']);
//field of event name decoration
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade800,
                                Colors.deepPurple.shade400
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.event, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      eventTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      eventDate,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<MenuAction>(
                                onSelected: (MenuAction action) {
                                  switch (action) {
                                    case MenuAction.edit:
                                      _editEvent(docId, eventTitle,
                                          entry.value['date']);
                                      break;
                                    case MenuAction.delete:
                                      _deleteEvent(docId);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                    value: MenuAction.edit,
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: MenuAction.delete,
                                    child: Text('Delete'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEventDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddEventDialog() {
    DateTime selectedDate = DateTime.now();
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.grey.shade900,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Add Event",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: eventController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Event Name',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(data: ThemeData.dark(), child: child!);
                        },
                      );
                      if (picked != null) {
                        selectedDate = picked;
                      }
                    },
                    child: const Text("Pick Date"),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final eventName = eventController.text.trim();

                          if (eventName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Event name cannot be empty'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final eventDate = Timestamp.fromDate(selectedDate);
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('events')
                              .add({
                            'title': eventName,
                            'date': eventDate,
                          });

                          await loadEventsForMonth();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Save",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

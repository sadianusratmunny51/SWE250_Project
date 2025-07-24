import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, double>> fetchGroupedExpenses(DateTime selectedDate) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final Map<String, double> grouped = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final type = (data['type'] as String?)?.toLowerCase().trim() ?? 'others';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      grouped[type] = (grouped[type] ?? 0.0) + amount;
    }

    return grouped;
  }
}

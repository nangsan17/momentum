import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/habit_model.dart';

class HabitService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final CollectionReference _habitRef =
      FirebaseFirestore.instance.collection(
        'habits',
      );

  Stream<List<HabitModel>> getHabits() {
    return _habitRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        return HabitModel.fromMap(data);
      }).toList();
    });
  }

  Future<void> addHabit(
    String title,
    String emoji,
    String category,
  ) async {
    final doc = _habitRef.doc();

    final habit = HabitModel(
      id: doc.id,
      title: title,
      completed: false,
      streak: 0,
      emoji: emoji,
      category: category,
      completedDates: [],
    );

    await doc.set(habit.toMap());
  }

  Future<void> deleteHabit(String id) async {
    await _habitRef.doc(id).delete();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _habitRef.doc(habit.id).update(habit.toMap());
  }

  Future<void> toggleHabit(HabitModel habit) async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';

    List<String> updatedDates = List.from(habit.completedDates);

    bool isCompletedToday = updatedDates.contains(today);

    if (isCompletedToday) {
      updatedDates.remove(today);
    } else {
      updatedDates.add(today);
    }

    await _habitRef.doc(habit.id).update({
      'completed': !habit.completed,
      'streak': !habit.completed
          ? habit.streak + 1
          : habit.streak > 0
              ? habit.streak - 1
              : 0,
      'completedDates': updatedDates,
    });
  }
}
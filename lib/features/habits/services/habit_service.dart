import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/habit_model.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Each user gets their own habits subcollection
  CollectionReference get _habitRef {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(uid).collection('habits');
  }

  Stream<List<HabitModel>> getHabits() {
    return _habitRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        final habit = HabitModel.fromMap(data);

        // Auto reset streak if yesterday was missed
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayStr =
            '${yesterday.year}-${yesterday.month}-${yesterday.day}';
        final todayStr = '${now.year}-${now.month}-${now.day}';

        final hasToday = habit.completedDates.contains(todayStr);
        final hasYesterday = habit.completedDates.contains(yesterdayStr);

        if (!hasToday && !hasYesterday && habit.streak > 0) {
          // Streak should be reset — update silently
          _habitRef.doc(habit.id).update({'streak': 0});
          return habit.copyWith(streak: 0);
        }

        return habit;
      }).toList();
    });
  }

  Future<String?> addHabit(
    String title,
    String emoji,
    String category, {
    bool reminderEnabled = false,
    String? reminderTime,
  }) async {
    final doc = _habitRef.doc();

    final habit = HabitModel(
      id: doc.id,
      title: title,
      completed: false,
      streak: 0,
      emoji: emoji,
      category: category,
      completedDates: [],
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );

    await doc.set(habit.toMap());
    return doc.id;
  }

  Future<void> deleteHabit(String id) async {
    await _habitRef.doc(id).delete();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _habitRef.doc(habit.id).update(habit.toMap());
  }

  Future<void> toggleHabit(
    HabitModel habit, {
    String mood = "",
    String reflection = "",
  }) async {
    final now = DateTime.now();

    final today = '${now.year}-${now.month}-${now.day}';

    List<String> updatedDates = List.from(habit.completedDates);

    bool isCompletedToday = updatedDates.contains(today);

    if (isCompletedToday) {
      updatedDates.remove(today);
    } else {
      updatedDates.add(today);
    }
    final userRef = _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final userDoc = await userRef.get();

    int currentXp = userDoc.data()?['xp'] ?? 0;

    // gain XP only when completing
    if (!isCompletedToday) {
      currentXp += 10;
    }

    await userRef.update({'xp': currentXp});

    await _habitRef.doc(habit.id).update({
      'completed': !habit.completed,

      'streak': !habit.completed
          ? habit.streak + 1
          : habit.streak > 0
          ? habit.streak - 1
          : 0,

      'completedDates': updatedDates,

      'mood': mood,

      'reflection': reflection,
    });
  }
}

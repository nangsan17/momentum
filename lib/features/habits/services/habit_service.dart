import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/habit_model.dart';

class HabitService {
  final _firestore =
      FirebaseFirestore.instance;

  final user =
      FirebaseAuth.instance.currentUser;

  CollectionReference get _habitRef =>
      _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('habits');

  Stream<List<HabitModel>> getHabits() {
    return _habitRef.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return HabitModel.fromMap(
            doc.data()
                as Map<String, dynamic>,
          );
        }).toList();
      },
    );
  }

  Future<void> addHabit(
    String title,
    String emoji,
  ) async {
    final doc = _habitRef.doc();

    final habit = HabitModel(
      id: doc.id,
      title: title,
      emoji: emoji,
      completed: false,
      streak: 0,
      lastCompleted: null,
    );

    await doc.set(habit.toMap());
  }

  Future<void> updateHabit(
    String id,
    String newTitle,
  ) async {
    await _habitRef.doc(id).update({
      'title': newTitle,
    });
  }

  Future<void> deleteHabit(
    String id,
  ) async {
    await _habitRef.doc(id).delete();
  }

  Future<void> toggleHabit(
    HabitModel habit,
  ) async {
    final now = DateTime.now();

    int newStreak = habit.streak;

    if (!habit.completed) {
      if (habit.lastCompleted != null) {
        final difference = now
            .difference(
              habit.lastCompleted!,
            )
            .inDays;

        if (difference == 1) {
          newStreak += 1;
        } else if (difference > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }
    } else {
      newStreak =
          newStreak > 0
              ? newStreak - 1
              : 0;
    }

    await _habitRef.doc(habit.id).update({
      'completed': !habit.completed,
      'streak': newStreak,
      'lastCompleted':
          now.toIso8601String(),
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/habit_model.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final user = FirebaseAuth.instance.currentUser;

  Future<void> addHabit(HabitModel habit) async {
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('habits')
        .doc(habit.id)
        .set(habit.toMap());
  }

  Stream<List<HabitModel>> getHabits() {
    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('habits')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HabitModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('habits')
        .doc(habit.id)
        .update(habit.toMap());
  }
  Future<void> toggleHabit(HabitModel habit) async {
  final updatedHabit = HabitModel(
    id: habit.id,
    title: habit.title,
    completed: !habit.completed,
    streak: !habit.completed
        ? habit.streak + 1
        : 0,
  );

  await updateHabit(updatedHabit);
}
}
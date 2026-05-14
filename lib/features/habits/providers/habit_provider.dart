import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_model.dart';
import '../services/habit_service.dart';

final habitServiceProvider =
    Provider<HabitService>((ref) {

  return HabitService();
});

final habitProvider =
    StreamProvider<List<HabitModel>>((
      ref,
    ) {

  return ref
      .watch(habitServiceProvider)
      .getHabits();
});
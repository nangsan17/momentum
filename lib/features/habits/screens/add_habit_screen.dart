import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/widgets/primary_button.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final titleController = TextEditingController();

  Future<void> saveHabit() async {
  if (titleController.text.trim().isEmpty) return;

  final habit = HabitModel(
    id: const Uuid().v4(),
    title: titleController.text.trim(),
    completed: false,
    streak: 0,
  );

  await ref.read(habitServiceProvider).addHabit(habit);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Habit added successfully 🔥',
        ),
      ),
    );

    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Habit name',
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Save Habit',
              onPressed: saveHabit,
            ),
          ],
        ),
      ),
    );
  }
}
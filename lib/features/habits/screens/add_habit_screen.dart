import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/habit_provider.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final titleController = TextEditingController();

  String selectedEmoji = '🔥';

  String selectedCategory = 'General';

  final emojis = ['🔥', '💧', '📚', '🏃', '💪', '🧘', '🎯', '🥗'];

  final categories = ['General', 'Health', 'Study', 'Fitness', 'Productivity'];

  Future<void> saveHabit() async {
    if (titleController.text.trim().isEmpty) {
      return;
    }

    await ref
        .read(habitServiceProvider)
        .addHabit(titleController.text.trim(), selectedEmoji, selectedCategory);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            TextField(
              controller: titleController,

              decoration: InputDecoration(
                hintText: 'Habit title',

                filled: true,

                fillColor: isDark ? Colors.grey.shade900 : Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Choose Emoji',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,

              children: emojis.map((emoji) {
                final selected = selectedEmoji == emoji;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEmoji = emoji;
                    });
                  },

                  child: Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: selected ? Colors.orange : Colors.grey.shade300,

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: selectedCategory,

              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },

              decoration: InputDecoration(
                filled: true,

                fillColor: isDark ? Colors.grey.shade900 : Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: saveHabit,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,

                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),

                child: const Text('Save Habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

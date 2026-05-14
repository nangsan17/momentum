import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
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
  bool reminderEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 0);

  final emojis = ['🔥', '💧', '📚', '🏃', '💪', '🧘', '🎯', '🥗'];
  final categories = ['General', 'Health', 'Study', 'Fitness', 'Productivity'];

  Future<void> pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null) {
      setState(() => reminderTime = picked);
    }
  }

  Future<void> saveHabit() async {
    if (titleController.text.trim().isEmpty) return;

    final timeString = reminderEnabled
        ? '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}'
        : null;

    final habitId = await ref.read(habitServiceProvider).addHabit(
          titleController.text.trim(),
          selectedEmoji,
          selectedCategory,
          reminderEnabled: reminderEnabled,
          reminderTime: timeString,
        );

    if (reminderEnabled && habitId != null) {
      await NotificationService().scheduleHabitReminder(
        habitId: habitId,
        habitTitle: titleController.text.trim(),
        emoji: selectedEmoji,
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
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

            // EMOJI
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
                  onTap: () => setState(() => selectedEmoji = emoji),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // CATEGORY
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                    value: category, child: Text(category));
              }).toList(),
              onChanged: (value) =>
                  setState(() => selectedCategory = value!),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // REMINDER
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: reminderEnabled,
                    activeColor: AppColors.primary,
                    title: const Text(
                      'Daily Reminder 🔔',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Get notified to complete this habit'),
                    onChanged: (value) =>
                        setState(() => reminderEnabled = value),
                  ),
                  if (reminderEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.access_time,
                          color: AppColors.primary),
                      title: const Text('Reminder Time'),
                      trailing: GestureDetector(
                        onTap: pickReminderTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reminderTime.format(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // SAVE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Habit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
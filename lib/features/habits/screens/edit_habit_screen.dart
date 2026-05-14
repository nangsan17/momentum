import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final HabitModel habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  late TextEditingController titleController;
  String selectedEmoji = '🔥';
  bool reminderEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 0);

  final emojis = ['🔥', '💧', '📚', '🏃', '💪', '🧘', '🎯', '🥗'];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.habit.title);
    selectedEmoji = widget.habit.emoji;
    reminderEnabled = widget.habit.reminderEnabled;

    if (widget.habit.reminderTime != null) {
      final parts = widget.habit.reminderTime!.split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null) setState(() => reminderTime = picked);
  }

  Future<void> updateHabit() async {
    final timeString = reminderEnabled
        ? '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}'
        : null;

    final updated = widget.habit.copyWith(
      title: titleController.text.trim(),
      emoji: selectedEmoji,
      reminderEnabled: reminderEnabled,
      reminderTime: timeString,
    );

    await ref.read(habitServiceProvider).updateHabit(updated);

    if (reminderEnabled) {
      await NotificationService().scheduleHabitReminder(
        habitId: updated.id,
        habitTitle: updated.title,
        emoji: updated.emoji,
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      );
    } else {
      await NotificationService().cancelHabitReminder(updated.id);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> deleteHabit() async {
    await NotificationService().cancelHabitReminder(widget.habit.id);
    await ref.read(habitServiceProvider).deleteHabit(widget.habit.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Habit')),
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
                    subtitle:
                        const Text('Get notified to complete this habit'),
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

            const SizedBox(height: 24),

            // REMINDER STATUS on card
            if (widget.habit.reminderEnabled &&
                widget.habit.reminderTime != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Currently reminding at ${widget.habit.reminderTime}',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),

            // SAVE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // DELETE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Habit?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) deleteHabit();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Delete Habit',
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
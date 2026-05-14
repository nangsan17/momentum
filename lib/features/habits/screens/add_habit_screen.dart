import 'package:animate_do/animate_do.dart';
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
  if (picked != null) setState(() => reminderTime = picked);
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Habit title',
                      prefixIcon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Choose Emoji',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: emojis.map((emoji) {
                      final selected = selectedEmoji == emoji;
                      return GestureDetector(
                        onTap: () => setState(() => selectedEmoji = emoji),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: selected
                                ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                                : null,
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategory = value!),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
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
                          onChanged: (value) => setState(() => reminderEnabled = value),
                        ),
                        if (reminderEnabled) ...[
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.access_time, color: AppColors.primary),
                            title: const Text('Reminder Time'),
                            trailing: GestureDetector(
                              onTap: pickReminderTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  reminderTime.format(context),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Save Habit',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
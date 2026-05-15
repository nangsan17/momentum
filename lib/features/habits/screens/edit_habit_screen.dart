import 'package:animate_do/animate_do.dart';
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
  int selectedHour = reminderTime.hour;
  int selectedMinute = reminderTime.minute;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Set Reminder Time'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hour', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setStateDialog(() {
                    selectedHour = (selectedHour - 1 + 24) % 24;
                  }),
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedHour.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => setStateDialog(() {
                    selectedHour = (selectedHour + 1) % 24;
                  }),
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Minute', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setStateDialog(() {
                    selectedMinute = (selectedMinute - 5 + 60) % 60;
                  }),
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedMinute.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => setStateDialog(() {
                    selectedMinute = (selectedMinute + 5) % 60;
                  }),
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                reminderTime = TimeOfDay(hour: selectedHour, minute: selectedMinute);
              });
              Navigator.pop(context);
            },
            child: const Text('Set Time'),
          ),
        ],
      ),
    ),
  );
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

  Future<void> useStreakFreeze() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Use Streak Freeze? 🧊'),
        content: const Text(
          'A streak freeze protects your streak for 1 missed day.\n\nThis will mark yesterday as completed to save your streak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Use Freeze'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

      final updatedDates = List<String>.from(widget.habit.completedDates);
      if (!updatedDates.contains(yesterdayStr)) {
        updatedDates.add(yesterdayStr);
      }

      final updated = widget.habit.copyWith(
        completedDates: updatedDates,
        streak: widget.habit.streak + 1,
      );

      await ref.read(habitServiceProvider).updateHabit(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❄️ Streak freeze used! Your streak is safe.'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Habit'), centerTitle: true),
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
                            color: selected
                                ? AppColors.primary
                                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
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

                // REMINDER
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
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

                if (widget.habit.reminderEnabled && widget.habit.reminderTime != null) ...[
                  const SizedBox(height: 12),
                  FadeInDown(
                    delay: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Currently reminding at ${widget.habit.reminderTime}',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // STREAK FREEZE CARD
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400.withOpacity(0.15),
                          Colors.cyan.shade300.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('🧊', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Streak Freeze',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Missed yesterday? Save your streak!',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: useStreakFreeze,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Use ❄️',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SAVE
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updateHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // DELETE
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: const Text('Delete Habit?'),
                            content: const Text('This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) deleteHabit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Delete Habit',
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
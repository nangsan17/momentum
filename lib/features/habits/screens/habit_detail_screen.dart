import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final HabitModel habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  String aiInsight() {
    if (widget.habit.streak >= 10) return '👑 You\'re unstoppable with this habit.';
    if (widget.habit.streak >= 5) return '🔥 Strong momentum. Keep pushing.';
    if (widget.habit.completedDates.length <= 2) return '🌱 Small starts create big results.';
    return '🚀 Consistency is improving. Keep going!';
  }

  Color get streakColor {
    if (widget.habit.streak >= 10) return const Color(0xFF6D5DF6);
    if (widget.habit.streak >= 5) return AppColors.primary;
    return Colors.teal;
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
            child: const Text('Use Freeze ❄️'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr =
          '${yesterday.year}-${yesterday.month}-${yesterday.day}';

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
    final totalDone = widget.habit.completedDates.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // HEADER CARD
                FadeInDown(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [streakColor, streakColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: streakColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(widget.habit.emoji,
                            style: const TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        Text(
                          widget.habit.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.habit.category,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // STATS ROW
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildStat('🔥', '${widget.habit.streak}',
                            'Current Streak', context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildStat(
                            '🏆', '$totalDone', 'Total Done', context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // COMPLETION STATUS
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: widget.habit.completed
                          ? Colors.green.withOpacity(0.1)
                          : (isDark
                              ? Colors.grey.shade800
                              : Colors.orange.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.habit.completed
                            ? Colors.green.withOpacity(0.4)
                            : AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.habit.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: widget.habit.completed
                              ? Colors.green
                              : AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.habit.completed
                                  ? 'Completed Today! 🎉'
                                  : 'Not done yet today',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: widget.habit.completed
                                    ? Colors.green
                                    : AppColors.primary,
                              ),
                            ),
                            Text(
                              widget.habit.completed
                                  ? 'Great job keeping your streak!'
                                  : 'You can still do it today!',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // STREAK FREEZE CARD
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400.withOpacity(0.15),
                          Colors.cyan.shade300.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                          child: const Text('🧊',
                              style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Streak Freeze ❄️',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Missed yesterday? Save your streak!',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: useStreakFreeze,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
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

                // REMINDER
                if (widget.habit.reminderEnabled &&
                    widget.habit.reminderTime != null)
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_active,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daily Reminder 🔔',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Reminds you at ${widget.habit.reminderTime}',
                                style:
                                    TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // AI COACH
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6D5DF6).withOpacity(0.12),
                          const Color(0xFF46A0FF).withOpacity(0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF6D5DF6).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6D5DF6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('🤖',
                              style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI Coach',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                aiInsight(),
                                style:
                                    TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // RECENT ACTIVITY
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      widget.habit.completedDates.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'No activity yet. Start completing this habit! 🚀',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.habit.completedDates.reversed
                                  .take(10)
                                  .map(
                                    (e) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStat(
    String emoji,
    String value,
    String title,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
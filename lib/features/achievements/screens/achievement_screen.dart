import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../habits/providers/habit_provider.dart';
import '../models/achievement_model.dart';

class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements 🏆')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: habitsAsync.when(
            data: (habits) {
              final completedCount = habits.where((h) => h.completed).length;
              final longestStreak = habits.isEmpty
                  ? 0
                  : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

              final achievements = [
                AchievementModel(
                  title: 'First Habit',
                  description: 'Create your first habit',
                  emoji: '🚀',
                  unlocked: habits.isNotEmpty,
                ),
                AchievementModel(
                  title: '7 Day Streak',
                  description: 'Reach a 7 day streak',
                  emoji: '🔥',
                  unlocked: longestStreak >= 7,
                ),
                AchievementModel(
                  title: 'Consistency King',
                  description: 'Complete 30 habits total',
                  emoji: '👑',
                  unlocked: completedCount >= 30,
                ),
                AchievementModel(
                  title: 'Productivity Master',
                  description: 'Create 10 habits',
                  emoji: '📚',
                  unlocked: habits.length >= 10,
                ),
                AchievementModel(
                  title: 'Fitness Warrior',
                  description: 'Complete a fitness habit',
                  emoji: '💪',
                  unlocked: habits.any((h) => h.category == 'Fitness' && h.completed),
                ),
                AchievementModel(
                  title: 'Healthy Life',
                  description: 'Complete a health habit',
                  emoji: '🥗',
                  unlocked: habits.any((h) => h.category == 'Health' && h.completed),
                ),
              ];

              final unlockedCount = achievements.where((a) => a.unlocked).length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Text(
                        'Your Badges 🏅',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        '$unlockedCount/${achievements.length} achievements unlocked',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PROGRESS BAR
                    FadeInDown(
                      delay: const Duration(milliseconds: 150),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: unlockedCount / achievements.length,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: achievements.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: achievement.unlocked
                                  ? Theme.of(context).cardColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(24),
                              border: achievement.unlocked
                                  ? Border.all(color: AppColors.primary, width: 2)
                                  : null,
                              boxShadow: achievement.unlocked
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  achievement.emoji,
                                  style: TextStyle(
                                    fontSize: achievement.unlocked ? 54 : 44,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  achievement.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: achievement.unlocked
                                        ? null
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  achievement.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Icon(
                                  achievement.unlocked ? Icons.verified : Icons.lock,
                                  color: achievement.unlocked ? Colors.green : Colors.grey,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            error: (e, _) => Center(child: Text(e.toString())),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
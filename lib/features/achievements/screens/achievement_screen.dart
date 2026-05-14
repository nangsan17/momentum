import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../habits/providers/habit_provider.dart';
import '../models/achievement_model.dart';

class AchievementScreen
    extends ConsumerWidget {
  const AchievementScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final habitsAsync =
        ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achievements 🏆',
        ),
      ),

      body: habitsAsync.when(
        data: (habits) {
          final completedCount = habits
              .where(
                (h) => h.completed,
              )
              .length;

          final longestStreak =
              habits.isEmpty
                  ? 0
                  : habits
                      .map(
                        (h) => h.streak,
                      )
                      .reduce(
                        (a, b) =>
                            a > b ? a : b,
                      );

          final achievements = [
            AchievementModel(
              title: 'First Habit',
              description:
                  'Create your first habit',
              emoji: '🚀',

              unlocked:
                  habits.isNotEmpty,
            ),

            AchievementModel(
              title: '7 Day Streak',
              description:
                  'Reach a 7 day streak',
              emoji: '🔥',

              unlocked:
                  longestStreak >= 7,
            ),

            AchievementModel(
              title:
                  'Consistency King',
              description:
                  'Complete 30 habits',
              emoji: '👑',

              unlocked:
                  completedCount >= 30,
            ),

            AchievementModel(
              title:
                  'Productivity Master',
              description:
                  'Create 10 habits',
              emoji: '📚',

              unlocked:
                  habits.length >= 10,
            ),

            AchievementModel(
              title:
                  'Fitness Warrior',
              description:
                  'Complete fitness goals',
              emoji: '💪',

              unlocked:
                  habits.any(
                    (h) =>
                        h.category ==
                            'Fitness' &&
                        h.completed,
                  ),
            ),

            AchievementModel(
              title: 'Healthy Life',
              description:
                  'Complete health habits',
              emoji: '🥗',

              unlocked:
                  habits.any(
                    (h) =>
                        h.category ==
                            'Health' &&
                        h.completed,
                  ),
            ),
          ];

          final unlockedCount =
              achievements
                  .where(
                    (a) => a.unlocked,
                  )
                  .length;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Your Badges 🏅',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  '$unlockedCount/${achievements.length} achievements unlocked',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 28),

                GridView.builder(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount:
                      achievements.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,

                        crossAxisSpacing:
                            16,

                        mainAxisSpacing:
                            16,

                        childAspectRatio:
                            0.9,
                      ),

                  itemBuilder:
                      (context, index) {
                    final achievement =
                        achievements[index];

                    return Container(
                      padding:
                          const EdgeInsets.all(
                            20,
                          ),

                      decoration:
                          BoxDecoration(
                            color:
                                achievement
                                        .unlocked
                                    ? Theme.of(
                                        context,
                                      ).cardColor
                                    : Colors
                                        .grey
                                        .shade300,

                            borderRadius:
                                BorderRadius.circular(
                                  24,
                                ),

                            border:
                                achievement
                                        .unlocked
                                    ? Border.all(
                                      color:
                                          AppColors.primary,
                                      width:
                                          2,
                                    )
                                    : null,
                          ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Text(
                            achievement
                                .emoji,

                            style:
                                const TextStyle(
                                  fontSize:
                                      54,
                                ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Text(
                            achievement
                                .title,

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                const TextStyle(
                                  fontSize:
                                      18,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Text(
                            achievement
                                .description,

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Icon(
                            achievement
                                    .unlocked
                                ? Icons
                                    .verified
                                : Icons.lock,

                            color:
                                achievement
                                        .unlocked
                                    ? Colors
                                        .green
                                    : Colors
                                        .grey,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },

        error: (e, _) => Center(
          child: Text(
            e.toString(),
          ),
        ),

        loading: () => const Center(
          child:
              CircularProgressIndicator(),
        ),
      ),
    );
  }
}
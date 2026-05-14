import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../habits/providers/habit_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final habitsAsync = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Heatmap 🔥',
        ),
      ),

      body: habitsAsync.when(
        data: (habits) {
          // REAL DATASET
          final Map<DateTime, int> datasets = {};

          for (final habit in habits) {
            for (final date
                in habit.completedDates) {
              final parts =
                  date.split('-');

              final parsedDate = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );

              datasets.update(
                parsedDate,
                (value) => value + 1,
                ifAbsent: () => 1,
              );
            }
          }

          final totalCompleted = habits
              .where(
                (habit) => habit.completed,
              )
              .length;

          final now = DateTime.now();

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Consistency Tracker 🚀',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  'Track your productivity every day',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding:
                      const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color:
                        Theme.of(context)
                            .cardColor,
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),

                  child: HeatMap(
                    startDate: DateTime(
                      now.year,
                      now.month,
                      now.day - 90,
                    ),

                    endDate: now,

                    datasets: datasets,

                    colorMode:
                        ColorMode.opacity,

                    showColorTip: false,

                    scrollable: true,

                    defaultColor:
                        Colors.grey.shade300,

                    textColor:
                        Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color,

                    colorsets: {
                      1: AppColors.primary
                          .withOpacity(0.2),

                      3: AppColors.primary
                          .withOpacity(0.4),

                      5: AppColors.primary
                          .withOpacity(0.6),

                      7: AppColors.primary
                          .withOpacity(0.8),

                      10: AppColors.primary,
                    },

                    onClick:
                        (value) {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            '${value.day}/${value.month}/${value.year}',
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: buildStatCard(
                        context,
                        title:
                            'Completed Today',
                        value:
                            totalCompleted
                                .toString(),
                        emoji: '✅',
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: buildStatCard(
                        context,
                        title:
                            'Active Habits',
                        value:
                            habits.length
                                .toString(),
                        emoji: '🔥',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'Your consistency builds momentum 💪',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 16,
                  ),
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

  Widget buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String emoji,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color:
            Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          Text(
            emoji,
            style:
                const TextStyle(fontSize: 34),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
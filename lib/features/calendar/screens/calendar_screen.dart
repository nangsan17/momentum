import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../habits/providers/habit_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Heatmap 🔥')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: habitsAsync.when(
            data: (habits) {
              final Map<DateTime, int> datasets = {};
              for (final habit in habits) {
                for (final date in habit.completedDates) {
                  final parts = date.split('-');
                  final parsedDate = DateTime(
                    int.parse(parts[0]),
                    int.parse(parts[1]),
                    int.parse(parts[2]),
                  );
                  datasets.update(parsedDate, (v) => v + 1, ifAbsent: () => 1);
                }
              }

              final totalCompleted = habits.where((h) => h.completed).length;
              final now = DateTime.now();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Text(
                        'Consistency Tracker 🚀',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'Track your productivity every day',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: HeatMap(
                          startDate: DateTime(
                            now.year,
                            now.month,
                            now.day - 90,
                          ),
                          endDate: now,
                          datasets: datasets,
                          colorMode: ColorMode.opacity,
                          showColorTip: false,
                          scrollable: true,
                          defaultColor: Colors.grey.shade300,
                          textColor: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color,
                          colorsets: {
                            1: AppColors.primary.withOpacity(0.2),
                            3: AppColors.primary.withOpacity(0.4),
                            5: AppColors.primary.withOpacity(0.6),
                            7: AppColors.primary.withOpacity(0.8),
                            10: AppColors.primary,
                          },
                          onClick: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${value.day}/${value.month}/${value.year}',
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Row(
                        children: [
                          Expanded(
                            child: buildStatCard(
                              context,
                              title: 'Completed Today',
                              value: totalCompleted.toString(),
                              emoji: '✅',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: buildStatCard(
                              context,
                              title: 'Active Habits',
                              value: habits.length.toString(),
                              emoji: '🔥',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'Your consistency builds momentum 💪',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
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

  Widget buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String emoji,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

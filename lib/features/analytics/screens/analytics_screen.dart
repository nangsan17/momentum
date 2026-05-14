import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../habits/providers/habit_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics 📊')),

      body: habitsAsync.when(
        data: (habits) {
          final totalHabits = habits.length;

          final completedHabits = habits
              .where((habit) => habit.completed)
              .length;

          final pendingHabits = totalHabits - completedHabits;

          final completionRate = totalHabits == 0
              ? 0.0
              : completedHabits / totalHabits;

          final longestStreak = habits.isEmpty
              ? 0
              : habits
                    .map((habit) => habit.streak)
                    .reduce((a, b) => a > b ? a : b);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress 🔥',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  'Track your habit consistency',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),

                const SizedBox(height: 28),

                // STATS
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,

                  children: [
                    buildStatCard(
                      context,
                      title: 'Total Habits',
                      value: totalHabits.toString(),
                      emoji: '📚',
                    ),

                    buildStatCard(
                      context,
                      title: 'Completed',
                      value: completedHabits.toString(),
                      emoji: '✅',
                    ),

                    buildStatCard(
                      context,
                      title: 'Pending',
                      value: pendingHabits.toString(),
                      emoji: '⏳',
                    ),

                    buildStatCard(
                      context,
                      title: 'Longest Streak',
                      value: '$longestStreak days',
                      emoji: '🔥',
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'Completion Rate',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 20),

                // PIE CHART
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Column(
                    children: [
                      SizedBox(
                        height: 240,

                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 60,

                            sections: [
                              PieChartSectionData(
                                value: completedHabits.toDouble(),

                                color: AppColors.primary,

                                radius: 55,

                                title:
                                    '${(completionRate * 100).toStringAsFixed(0)}%',

                                titleStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              PieChartSectionData(
                                value: pendingHabits.toDouble(),

                                color: Colors.grey.shade400,

                                radius: 45,
                                title: '',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Text('Completed'),

                          const SizedBox(width: 24),

                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Text('Pending'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Weekly Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 20),

                // BAR CHART
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: SizedBox(
                    height: 260,

                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),

                        borderData: FlBorderData(show: false),

                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,

                              getTitlesWidget: (value, meta) {
                                const days = [
                                  'M',
                                  'T',
                                  'W',
                                  'T',
                                  'F',
                                  'S',
                                  'S',
                                ];

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(days[value.toInt()]),
                                );
                              },
                            ),
                          ),
                        ),

                        barGroups: [
                          buildBar(0, 3),
                          buildBar(1, 5),
                          buildBar(2, 2),
                          buildBar(3, 6),
                          buildBar(4, 4),
                          buildBar(5, 7),
                          buildBar(6, 5),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },

        error: (e, _) => Center(child: Text(e.toString())),

        loading: () => const Center(child: CircularProgressIndicator()),
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
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),

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

  static BarChartGroupData buildBar(int x, double y) {
    return BarChartGroupData(
      x: x,

      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}

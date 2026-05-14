import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../habits/models/habit_model.dart';
import '../../habits/providers/habit_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  // Get real completions per day for last 7 days from completedDates
  List<double> getWeeklyData(List<HabitModel> habits) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dateStr = '${day.year}-${day.month}-${day.day}';
      return habits
          .where((h) => h.completedDates.contains(dateStr))
          .length
          .toDouble();
    });
  }

  int getWeeklyCompletedHabits(List<HabitModel> habits) {
    final now = DateTime.now();

    int total = 0;

    for (final habit in habits) {
      for (final date in habit.completedDates) {
        final parts = date.split('-');

        if (parts.length != 3) continue;

        final completedDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        final difference = now.difference(completedDate).inDays;

        if (difference >= 0 && difference < 7) {
          total++;
        }
      }
    }

    return total;
  }

  String generateAiInsight(List<HabitModel> habits) {
    if (habits.isEmpty) {
      return "Start your first habit, Momentum grows from small wins!!";
    }

    final completed = habits.where((h) => h.completed).length;

    final pending = habits.where((h) => !h.completed).length;

    final bestHabit = habits.reduce((a, b) => a.streak > b.streak ? a : b);

    final categoryMap = <String, int>{};

    for (var h in habits) {
      categoryMap[h.category] = (categoryMap[h.category] ?? 0) + 1;
    }

    final topCategory = categoryMap.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final completionRate = completed / habits.length;

    // strong streak
    if (bestHabit.streak >= 15) {
      return "👑 ${bestHabit.title} is dominating with a ${bestHabit.streak}-day streak. You're operating at elite consistency.";
    }

    // almost new record
    if (bestHabit.streak >= 7) {
      return "🔥 You're close to a new personal record. ${bestHabit.title} is carrying momentum.";
    }

    // productivity heavy
    if (topCategory == "Productivity") {
      return "⚡ Productivity dominates your habits. Consider balancing with Health or Fitness.";
    }

    // study heavy
    if (topCategory == "Study") {
      return "📚 You focus heavily on Study habits. Add breaks to avoid burnout.";
    }

    // low completion
    if (completionRate < .30) {
      return "👀 You're completing only ${(completionRate * 100).toInt()}% of habits today. Try reducing goals and build momentum.";
    }

    // many pending
    if (pending >= 5) {
      return "⏳ You have $pending pending habits. Finish one small task first.";
    }

    return "🚀 ${completed} habits completed today. Momentum is building!!";
  }

  String generateBehaviorInsight(List<HabitModel> habits) {
    if (habits.isEmpty) {
      return "🌱 Complete habits to unlock behavior insights.";
    }

    final moodCount = <String, int>{};

    final categoryMood = <String, int>{};

    int tiredCount = 0;

    int productiveCount = 0;

    for (final habit in habits) {
      if (habit.mood.isNotEmpty) {
        moodCount[habit.mood] = (moodCount[habit.mood] ?? 0) + 1;
      }

      if (habit.mood == "😩" ||
          habit.reflection.toLowerCase().contains("tired") ||
          habit.reflection.toLowerCase().contains("stress")) {
        tiredCount++;

        categoryMood[habit.category] = (categoryMood[habit.category] ?? 0) + 1;
      }

      if (habit.reflection.toLowerCase().contains("productive") ||
          habit.reflection.toLowerCase().contains("focused")) {
        productiveCount++;
      }
    }

    String topMood = moodCount.isEmpty
        ? "😐"
        : moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    String hardestCategory = categoryMood.isEmpty
        ? "None"
        : categoryMood.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    if (productiveCount >= 3) {
      return "🚀 You perform best on productive days. Your momentum spikes when you're focused.";
    }

    if (tiredCount >= 3) {
      return "💙 You often feel tired during $hardestCategory habits. Consider lighter goals on stressful days.";
    }

    if (topMood == "😄") {
      return "😄 Positive moods dominate your journey. You're building healthy consistency.";
    }

    if (topMood == "😩") {
      return "🧠 Your recent reflections show signs of burnout. Recovery matters too.";
    }

    return "🤖 AI is learning your behavior patterns over time.";
  }

  String getDayLabel(int index) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - index));
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return labels[day.weekday % 7];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics 📊')),
      body: habitsAsync.when(
        data: (habits) {
          final totalHabits = habits.length;
          final completedHabits = habits.where((h) => h.completed).length;
          final pendingHabits = totalHabits - completedHabits;
          final completionRate = totalHabits == 0
              ? 0.0
              : completedHabits / totalHabits;
          final longestStreak = habits.isEmpty
              ? 0
              : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
          final totalCompletions = habits
              .map((h) => h.completedDates.length)
              .fold(0, (a, b) => a + b);
          final weeklyData = getWeeklyData(habits);
          final weeklyCompleted = getWeeklyCompletedHabits(habits);

          const weeklyGoal = 7;

          final weeklyProgress = weeklyCompleted / weeklyGoal;

          final challengeCompleted = weeklyCompleted >= weeklyGoal;

          final maxY = weeklyData.isEmpty
              ? 5.0
              : weeklyData.reduce((a, b) => a > b ? a : b) + 1;

          // Best habit by streak
          final bestHabit = habits.isEmpty
              ? null
              : habits.reduce((a, b) => a.streak > b.streak ? a : b);

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

                // AI COACH
                Container(
                  margin: const EdgeInsets.only(bottom: 28),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6D5DF6), Color(0xFF46A0FF)],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text("🤖", style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Momentum AI Coach",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              generateAiInsight(habits),
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 28),

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,

                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                              ),

                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: const Text(
                              "🧠",
                              style: TextStyle(fontSize: 28),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Behavior Insights",

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    fontSize: 18,

                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  generateBehaviorInsight(habits),

                                  style: TextStyle(
                                    height: 1.5,

                                    fontSize: 14,

                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // STATS GRID
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
                      title: 'Completed Today',
                      value: completedHabits.toString(),
                      emoji: '✅',
                    ),
                    buildStatCard(
                      context,
                      title: 'Longest Streak',
                      value: '$longestStreak days',
                      emoji: '🔥',
                    ),
                    buildStatCard(
                      context,
                      title: 'Total Completions',
                      value: totalCompletions.toString(),
                      emoji: '🏆',
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                //Weekly Challenge
                Container(
                  margin: const EdgeInsets.only(bottom: 28),

                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: challengeCompleted
                          ? [const Color(0xFFFFB75E), const Color(0xFFED8F03)]
                          : [const Color(0xFF6D5DF6), const Color(0xFF46A0FF)],
                    ),

                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          const Text("🔥", style: TextStyle(fontSize: 34)),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  challengeCompleted
                                      ? "Challenge Complete!"
                                      : "Weekly Challenge",

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontSize: 22,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  challengeCompleted
                                      ? "You crushed this week's goal 🚀"
                                      : "Complete 7 habits this week",

                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: LinearProgressIndicator(
                          value: weeklyProgress.clamp(0, 1),

                          minHeight: 14,

                          backgroundColor: Colors.white24,

                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "$weeklyCompleted / $weeklyGoal completed",

                        style: const TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        challengeCompleted
                            ? "🏆 Bonus XP earned!"
                            : "${weeklyGoal - weeklyCompleted} habits left this week 👀",

                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // BEST HABIT CARD
                if (bestHabit != null && bestHabit.streak > 0) ...[
                  Text(
                    'Best Habit',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9B54), Color(0xFFFFB26B)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Text(
                          bestHabit.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bestHabit.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${bestHabit.streak} day streak 🔥',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // COMPLETION RATE
                Text(
                  'Completion Rate',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
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
                        child: totalHabits == 0
                            ? const Center(
                                child: Text(
                                  'No habits yet 🌱',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : PieChart(
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
                                      color: Colors.grey.shade300,
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
                          _legend(AppColors.primary, 'Completed'),
                          const SizedBox(width: 24),
                          _legend(Colors.grey.shade300, 'Pending'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // WEEKLY ACTIVITY — REAL DATA
                Text(
                  'Last 7 Days Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Habits completed per day',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SizedBox(
                    height: 260,
                    child: weeklyData.every((d) => d == 0)
                        ? const Center(
                            child: Text(
                              'No activity yet.\nStart completing habits! 🚀',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              maxY: maxY,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.shade200,
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) => Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        getDayLabel(value.toInt()),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              barGroups: List.generate(
                                7,
                                (i) => BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: weeklyData[i],
                                      width: 22,
                                      color: weeklyData[i] > 0
                                          ? AppColors.primary
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                // CATEGORY BREAKDOWN
                const SizedBox(height: 32),
                Text(
                  'By Category',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...buildCategoryBreakdown(context, habits),

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

  List<Widget> buildCategoryBreakdown(
    BuildContext context,
    List<HabitModel> habits,
  ) {
    final categories = <String, Map<String, int>>{};

    for (final habit in habits) {
      categories.putIfAbsent(
        habit.category,
        () => {'total': 0, 'completed': 0},
      );
      categories[habit.category]!['total'] =
          categories[habit.category]!['total']! + 1;
      if (habit.completed) {
        categories[habit.category]!['completed'] =
            categories[habit.category]!['completed']! + 1;
      }
    }

    if (categories.isEmpty) return [];

    return categories.entries.map((entry) {
      final total = entry.value['total']!;
      final completed = entry.value['completed']!;
      final rate = total == 0 ? 0.0 : completed / total;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$completed/$total',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: rate,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }).toList();
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

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

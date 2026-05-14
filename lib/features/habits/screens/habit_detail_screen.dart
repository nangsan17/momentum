import 'package:flutter/material.dart';
import '../models/habit_model.dart';

class HabitDetailScreen extends StatelessWidget {
  final HabitModel habit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
  });

  String aiInsight() {
    if (habit.streak >= 10) {
      return "👑 You're unstoppable with this habit.";
    }

    if (habit.streak >= 5) {
      return "🔥 Strong momentum. Keep pushing.";
    }

    if (habit.completedDates.length <= 2) {
      return "🌱 Small starts create big results.";
    }

    return "🚀 Consistency is improving.";
  }

  @override
  Widget build(BuildContext context) {
    final totalDone =
        habit.completedDates.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Habit Details",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(
              20,
            ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // HEADER
            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                    28,
                  ),

              decoration:
                  BoxDecoration(
                    gradient:
                        const LinearGradient(
                          colors: [
                            Color(
                              0xFFFF9B54,
                            ),
                            Color(
                              0xFFFFB26B,
                            ),
                          ],
                        ),

                    borderRadius:
                        BorderRadius.circular(
                          28,
                        ),
                  ),

              child: Column(
                children: [

                  Text(
                    habit.emoji,
                    style:
                        const TextStyle(
                          fontSize: 64,
                        ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    habit.title,

                    style:
                        const TextStyle(
                          color:
                              Colors.white,

                          fontSize:
                              28,

                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  Text(
                    habit.category,

                    style:
                        const TextStyle(
                          color:
                              Colors.white70,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Row(
              children: [

                Expanded(
                  child:
                      buildStat(
                    "🔥",
                    "${habit.streak}",
                    "Current",
                    context,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                      buildStat(
                    "🏆",
                    "$totalDone",
                    "Completed",
                    context,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 24,
            ),

            if (habit.reminderEnabled)
              buildSection(
                context,
                "Reminder 🔔",
                habit.reminderTime ??
                    "Not set",
              ),

            buildSection(
              context,
              "AI Coach 🤖",
              aiInsight(),
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              "Recent Activity",

              style:
                  Theme.of(context)
                      .textTheme
                      .headlineSmall,
            ),

            const SizedBox(
              height: 12,
            ),

            Wrap(
              spacing: 8,
              runSpacing: 8,

              children:
                  habit.completedDates
                      .reversed
                      .take(10)
                      .map(
                        (e) => Chip(
                          label:
                              Text(e),
                        ),
                      )
                      .toList(),
            ),
          ],
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
    return Container(
      padding:
          const EdgeInsets.all(
            20,
          ),

      decoration:
          BoxDecoration(
            color:
                Theme.of(context)
                    .cardColor,

            borderRadius:
                BorderRadius.circular(
                  24,
                ),
          ),

      child: Column(
        children: [

          Text(
            emoji,
            style:
                const TextStyle(
                  fontSize: 32,
                ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            value,

            style:
                const TextStyle(
                  fontSize: 22,

                  fontWeight:
                      FontWeight.bold,
                ),
          ),

          Text(title),
        ],
      ),
    );
  }

  Widget buildSection(
    BuildContext context,
    String title,
    String value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
            bottom: 18,
          ),

      padding:
          const EdgeInsets.all(
            18,
          ),

      decoration:
          BoxDecoration(
            color:
                Theme.of(context)
                    .cardColor,

            borderRadius:
                BorderRadius.circular(
                  22,
                ),
          ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style:
                const TextStyle(
                  fontWeight:
                      FontWeight.bold,

                  fontSize: 18,
                ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(value),
        ],
      ),
    );
  }
}
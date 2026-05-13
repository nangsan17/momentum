import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/habit_provider.dart';
import '../widgets/progress_card.dart';
import 'add_habit_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Momentum 🔥',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),

          child: habits.when(
            data: (habitList) {
              final completedHabits = habitList
                  .where((habit) => habit.completed)
                  .length;

              if (habitList.isEmpty) {
                return const Center(
                  child: Text(
                    'No habits yet.\nStart building momentum 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Good Morning ☀️',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Stay consistent today.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 24),

                  ProgressCard(
                    completed: completedHabits,
                    total: habitList.length,
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Today Habits',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  ...habitList.map((habit) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),

                      child: Row(
                        children: [
                          Checkbox(
                            value: habit.completed,

                            onChanged: (_) async {
                              await ref
                                  .read(habitServiceProvider)
                                  .toggleHabit(habit);
                            },
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  habit.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  '🔥 ${habit.streak} day streak',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },

            loading: () => const Center(child: CircularProgressIndicator()),

            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ),
      ),
    );
  }
}

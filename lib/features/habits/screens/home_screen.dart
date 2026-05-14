import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final searchController = TextEditingController();

  String selectedFilter = 'All';

  List<HabitModel> filterHabits(List<HabitModel> habits) {
    var filtered = habits;

    // SEARCH
    if (searchController.text.trim().isNotEmpty) {
      filtered = filtered.where((habit) {
        return habit.title.toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
      }).toList();
    }

    // COMPLETED
    if (selectedFilter == 'Completed') {
      filtered = filtered.where((habit) => habit.completed).toList();
    }
    // PENDING
    else if (selectedFilter == 'Pending') {
      filtered = filtered.where((habit) => !habit.completed).toList();
    }
    // CATEGORYS
    else if (selectedFilter != 'All') {
      filtered = filtered
          .where((habit) => habit.category == selectedFilter)
          .toList();
    }

    return filtered;
  }

  Widget buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),

        selected: selectedFilter == label,

        onSelected: (_) {
          setState(() {
            selectedFilter = label;
          });
        },
      ),
    );
  }

  String generateMoodReply(String text) {
    final input = text.toLowerCase();

    if (input.contains("tired") || input.contains("sleepy")) {
      return "😴 You seem tired today...drink more water and rest well!!";
    }

    if (input.contains("sad") ||
        input.contains("stress") ||
        input.contains("exam")) {
      return "💙 Tough days happen, relax yourself by doing yoga!";
    }

    if (input.contains("happy") || input.contains("productive")) {
      return "Ohooo You're in a strong zone today, Keep riding the momentum!!";
    }

    if (input.contains("gym")) {
      return "💪 Nice work. Physical consistency builds mental consistency too!!";
    }

    return "🔥 Great effort today!!";
  }

  Future<void> showMoodDialog(HabitModel habit) async {
    String mood = "😄";

    final noteController = TextEditingController();

    await showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: const Text("How did today feel?"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Wrap(
                spacing: 10,

                children: ["😄", "🙂", "😐", "😩"].map((e) {
                  return GestureDetector(
                    onTap: () {
                      mood = e;
                    },

                    child: Text(e, style: const TextStyle(fontSize: 36)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: noteController,

                decoration: const InputDecoration(hintText: "Reflection..."),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await ref
                    .read(habitServiceProvider)
                    .toggleHabit(
                      habit,

                      mood: mood,

                      reflection: noteController.text,
                    );
                if (!mounted) return;

                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text("🤖 AI Coach"),

                      content: Text(generateMoodReply(noteController.text)),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: const Text("Nice 🔥"),
                        ),
                      ],
                    );
                  },
                );
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Momentum')),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,

        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen()),
          );
        },
      ),

      body: habitsAsync.when(
        data: (habits) {
          final filteredHabits = filterHabits(habits);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),

                child: TextField(
                  controller: searchController,

                  onChanged: (_) {
                    setState(() {});
                  },

                  decoration: InputDecoration(
                    hintText: 'Search habits...',

                    prefixIcon: const Icon(Icons.search),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),

                      borderSide: BorderSide.none,
                    ),

                    filled: true,
                  ),
                ),
              ),

              SizedBox(
                height: 50,

                child: ListView(
                  scrollDirection: Axis.horizontal,

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  children: [
                    buildFilterChip('All'),

                    buildFilterChip('Completed'),

                    buildFilterChip('Pending'),

                    buildFilterChip('Health'),

                    buildFilterChip('Study'),

                    buildFilterChip('Fitness'),

                    buildFilterChip('Productivity'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: filteredHabits.isEmpty
                    ? const Center(child: Text('No habits found 🔥'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),

                        itemCount: filteredHabits.length,

                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),

                            child: Dismissible(
                              key: Key(habit.id),

                              background: Container(
                                alignment: Alignment.centerLeft,

                                padding: const EdgeInsets.only(left: 24),

                                decoration: BoxDecoration(
                                  color: Colors.green,

                                  borderRadius: BorderRadius.circular(24),
                                ),

                                child: const Icon(
                                  Icons.check,

                                  color: Colors.white,
                                ),
                              ),

                              secondaryBackground: Container(
                                alignment: Alignment.centerRight,

                                padding: const EdgeInsets.only(right: 24),

                                decoration: BoxDecoration(
                                  color: Colors.red,

                                  borderRadius: BorderRadius.circular(24),
                                ),

                                child: const Icon(
                                  Icons.delete,

                                  color: Colors.white,
                                ),
                              ),

                              onDismissed: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  await ref
                                      .read(habitServiceProvider)
                                      .toggleHabit(habit);
                                } else {
                                  await ref
                                      .read(habitServiceProvider)
                                      .deleteHabit(habit.id);
                                }
                              },

                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          HabitDetailScreen(habit: habit),
                                    ),
                                  );
                                },

                                child: Container(
                                  padding: const EdgeInsets.all(20),

                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,

                                    borderRadius: BorderRadius.circular(24),
                                  ),

                                  child: Row(
                                    children: [
                                      Text(
                                        habit.emoji,

                                        style: const TextStyle(fontSize: 40),
                                      ),

                                      const SizedBox(width: 18),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              habit.title,

                                              style: const TextStyle(
                                                fontSize: 24,

                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            Text(habit.category),

                                            const SizedBox(height: 6),

                                            Text(
                                              '🔥 ${habit.streak} day streak',
                                            ),

                                            if (habit.reminderEnabled &&
                                                habit.reminderTime != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),

                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .notifications_active,

                                                      size: 14,

                                                      color: AppColors.primary,
                                                    ),

                                                    const SizedBox(width: 4),

                                                    Text(habit.reminderTime!),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),

                                            onPressed: () {
                                              Navigator.push(
                                                context,

                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditHabitScreen(
                                                        habit: habit,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),

                                          Checkbox(
                                            value: habit.completed,

                                            onChanged: (_) async {
                                              if (!habit.completed) {
                                                showMoodDialog(habit);
                                              } else {
                                                await ref
                                                    .read(habitServiceProvider)
                                                    .toggleHabit(habit);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

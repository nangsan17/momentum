import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const HomeContent();
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  String selectedFilter = 'All';

  final searchController = TextEditingController();

  List<HabitModel> filterHabits(List<HabitModel> habits) {
    List<HabitModel> filtered = habits;

    // SEARCH
    if (searchController.text.isNotEmpty) {
      filtered = filtered.where((habit) {
        return habit.title.toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
      }).toList();
    }

    // FILTERS
    if (selectedFilter == 'Completed') {
      filtered = filtered.where((habit) => habit.completed).toList();
    } else if (selectedFilter == 'Pending') {
      filtered = filtered.where((habit) => !habit.completed).toList();
    } else if (selectedFilter != 'All') {
      filtered = filtered
          .where((habit) => habit.category == selectedFilter)
          .toList();
    }

    return filtered;
  }

  Widget buildFilterChip(String label) {
    final selected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedFilter = label;
          });
        },
      ),
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
              // SEARCH
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
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // FILTERS
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

              // HABITS
              Expanded(
                child: filteredHabits.isEmpty
                    ? const Center(
                        child: Text(
                          'No habits found 🔥',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
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
                                  size: 32,
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
                                  size: 32,
                                ),
                              ),

                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  return await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Delete Habit'),
                                      content: const Text('Are you sure?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return true;
                              },

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
                                          EditHabitScreen(habit: habit),
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

                                            const SizedBox(height: 4),

                                            Text(
                                              habit.category,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              '🔥 ${habit.streak} day streak',
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
                                              await ref
                                                  .read(habitServiceProvider)
                                                  .toggleHabit(habit);
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

        error: (e, _) => Center(child: Text(e.toString())),

        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

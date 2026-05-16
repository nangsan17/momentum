import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_service.dart';
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

    if (searchController.text.trim().isNotEmpty) {
      filtered = filtered.where((habit) {
        return habit.title.toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
      }).toList();
    }

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

  void showXpPopup({required bool levelUp, required int level}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            levelUp ? '🎉 LEVEL UP!' : '⚡ XP Gained',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                levelUp ? 'Welcome to Level $level 🚀' : '+10 XP earned!',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                levelUp
                    ? 'Your consistency is paying off 🔥'
                    : 'Small habits build big momentum.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nice 🔥'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showMoodDialog(HabitModel habit) async {
    String mood = '😄';
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'How did today feel?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['😄', '🙂', '😐', '😩'].map((e) {
                        final selected = mood == e;
                        return GestureDetector(
                          onTap: () => setStateDialog(() => mood = e),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(color: AppColors.primary)
                                  : null,
                            ),
                            child: Text(
                              e,
                              style: TextStyle(fontSize: selected ? 36 : 28),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add a reflection note...',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            const CircularProgressIndicator(
                              color: Color(0xFF6D5DF6),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'AI Coach is thinking...',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );

                    // Get real AI response
                    final aiReply = await AiService().getMoodResponse(
                      habitTitle: habit.title,
                      mood: mood,
                      reflection: noteController.text,
                      streak: habit.streak,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);

                    // Show AI response
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6D5DF6,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '🤖',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Coach',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Powered by Claude AI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6D5DF6),
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        content: Text(
                          aiReply,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Nice 🔥'),
                          ),
                        ],
                      ),
                    );

                    // XP popup
                    int newXp = 0;
                    try {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      newXp = userDoc.data()?['xp'] ?? 0;
                    } catch (_) {}

                    final level = (newXp ~/ 100) + 1;
                    final leveledUp = newXp % 100 == 0 && newXp > 0;

                    if (!mounted) return;
                    showXpPopup(levelUp: leveledUp, level: level);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Momentum'), centerTitle: true),
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
                  onChanged: (_) => setState(() {}),
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
                                            // Show last mood if exists
                                            if (habit.mood != null &&
                                                habit.mood!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Text(
                                                  'Last mood: ${habit.mood}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                  ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_model.dart';
import '../providers/habit_provider.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final HabitModel habit;

  const EditHabitScreen({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<EditHabitScreen> createState() =>
      _EditHabitScreenState();
}

class _EditHabitScreenState
    extends ConsumerState<EditHabitScreen> {

  late TextEditingController titleController;

  String selectedEmoji = '🔥';

  final emojis = [
    '🔥',
    '💧',
    '📚',
    '🏃',
    '💪',
    '🧘',
    '🎯',
    '🥗',
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.habit.title,
    );

    selectedEmoji = widget.habit.emoji;
  }

  Future<void> updateHabit() async {

    await ref
        .read(habitServiceProvider)
        .updateHabit(
          widget.habit.copyWith(
            title: titleController.text.trim(),
            emoji: selectedEmoji,
          ),
        );

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> deleteHabit() async {

    await ref
        .read(habitServiceProvider)
        .deleteHabit(widget.habit.id);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Scaffold(

      appBar: AppBar(
        title: const Text('Edit Habit'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            TextField(
              controller: titleController,

              decoration: InputDecoration(
                hintText: 'Habit title',

                filled: true,

                fillColor:
                    isDark
                        ? Colors.grey.shade900
                        : Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Choose Emoji',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,

              children:
                  emojis.map((emoji) {

                    final selected =
                        selectedEmoji == emoji;

                    return GestureDetector(

                      onTap: () {
                        setState(() {
                          selectedEmoji = emoji;
                        });
                      },

                      child: Container(
                        padding:
                            const EdgeInsets.all(12),

                        decoration: BoxDecoration(

                          color:
                              selected
                                  ? Colors.orange
                                  : Colors.grey.shade300,

                          borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                        ),

                        child: Text(
                          emoji,
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: updateHabit,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,

                  padding:
                      const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                ),

                child: const Text(
                  'Save Changes',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: () async {

                  final confirm =
                      await showDialog(

                        context: context,

                        builder:
                            (_) => AlertDialog(

                              title: const Text(
                                'Delete Habit?',
                              ),

                              content: const Text(
                                'This action cannot be undone.',
                              ),

                              actions: [

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      false,
                                    );
                                  },

                                  child: const Text(
                                    'Cancel',
                                  ),
                                ),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },

                                  child: const Text(
                                    'Delete',
                                  ),
                                ),
                              ],
                            ),
                      );

                  if (confirm == true) {
                    deleteHabit();
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,

                  padding:
                      const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                ),

                child: const Text(
                  'Delete Habit',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
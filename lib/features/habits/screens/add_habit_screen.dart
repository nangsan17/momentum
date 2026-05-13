import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen
    extends ConsumerStatefulWidget {
  const AddHabitScreen({
    super.key,
  });

  @override
  ConsumerState<AddHabitScreen>
  createState() =>
      _AddHabitScreenState();
}

class _AddHabitScreenState
    extends ConsumerState<AddHabitScreen> {
  final titleController =
      TextEditingController();

  String selectedEmoji = '🔥';

  final emojis = [
    '🔥',
    '💧',
    '📚',
    '🏃',
    '💪',
    '🧘',
    '🎯',
    '😴',
  ];

  Future<void> saveHabit() async {
    if (titleController.text
        .trim()
        .isEmpty) {
      return;
    }

    await ref
        .read(habitServiceProvider)
        .addHabit(
          titleController.text.trim(),
          selectedEmoji,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(
            content: Text(
              'Habit added successfully 🔥',
            ),
          ),
        );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,

        title: const Text(
          'New Habit',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
              ),

              child: TextField(
                controller:
                    titleController,

                decoration:
                    const InputDecoration(
                      border:
                          InputBorder.none,

                      hintText:
                          'Habit name',
                    ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 60,

              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal,

                itemCount: emojis.length,

                itemBuilder: (
                  _,
                  index,
                ) {
                  final emoji =
                      emojis[index];

                  final selected =
                      selectedEmoji ==
                          emoji;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedEmoji =
                            emoji;
                      });
                    },

                    child: Container(
                      margin:
                          const EdgeInsets.only(
                            right: 12,
                          ),

                      width: 55,
                      height: 55,

                      decoration:
                          BoxDecoration(
                            color:
                                selected
                                    ? AppColors
                                        .primary
                                    : Colors
                                        .white,

                            borderRadius:
                                BorderRadius.circular(
                                  16,
                                ),
                          ),

                      child: Center(
                        child: Text(
                          emoji,

                          style:
                              const TextStyle(
                                fontSize:
                                    28,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Save Habit',
              onPressed: saveHabit,
            ),
          ],
        ),
      ),
    );
  }
}